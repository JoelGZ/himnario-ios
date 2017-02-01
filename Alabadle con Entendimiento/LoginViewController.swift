	//
//  LoginViewController.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 10/6/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var crearUsuarioButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let usersRef = FIRDatabase.database().reference().child("users")
    
    var keyboardIsShowing = false
    var userUID: String?
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
     
        setupUI()
        
        // Keyboard subscriptions
        self.subscribeToKeyboardNotificationShow()
        self.subscribeToKeyboardNotificationHide()

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.unsubscribeFromKeyboardNotifications()
    }
    
    func checkReachability() {
        let reachability = Reachability()!
        
        reachability.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async() {
                FIRAuth.auth()?.addStateDidChangeListener() {auth, user in
                    if user != nil {
                        self.userUID = user?.uid
                        self.performSegue(withIdentifier: "loggedInSegue", sender: nil)
                        
                        //add user to db if it does not exist
                        let userToAdd = User(authData: user!)
                        if !self.userExists(email: userToAdd.email) {
                            let userItemRef = self.usersRef.child(userToAdd.uid)
                            
                            userItemRef.setValue(userToAdd.toAnyObject())
                        }
                        
                        guard let userData = user else { return }
                        let user = User(authData: userData)
                        self.defaults.set(user.uid, forKey: "USER_UID")
                        self.defaults.set(user.email, forKey: "USER_EMAIL")
                    }
                }
            }
        }
        
        reachability.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async() {
                let alert = UIAlertController(title: "Sin conexión...", message: "Ha perdido conexión con el servidor. Por favor revise su conexión y vuelva a intentar.", preferredStyle: UIAlertControllerStyle.alert)
                let regresarAction = UIAlertAction(title: "Reconectar", style: .default, handler: nil)
                alert.addAction(regresarAction)
                alert.popoverPresentationController?.sourceView = self.view
                alert.popoverPresentationController?.sourceRect = self.view.bounds
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loggedInSegue" {
            let tabBarController = segue.destination as! UITabBarController
            let splitViewController = tabBarController.viewControllers![1] as! UISplitViewController
            let rightNavController = splitViewController.viewControllers.last as! UINavigationController
            let detailViewController = rightNavController.topViewController as! DetailListViewController
            
            defaults.set(false, forKey: "LOG_SCREEN_VISIBLE")
            
            let listasDeUsuarioRef = FIRDatabase.database().reference().child("listas/\(userUID!)")
            listasDeUsuarioRef.observeSingleEvent(of: FIRDataEventType.value, with: {
                (snapshot) in
                if snapshot.hasChildren() {
                    var counter = 0
                    for listaID in snapshot.children {
                        counter += 1
                        if counter == Int(snapshot.childrenCount) {     // display last list
                            let listaIDStr = (listaID as! FIRDataSnapshot).key
                            let listaRef = listasDeUsuarioRef.child(listaIDStr)
                            listaRef.observeSingleEvent(of: FIRDataEventType.value, with: {(snap) in
                                let list = Lista(snapshot: snap, listaid: snap.key)
                                detailViewController.lista = list
                            })
                        }
                    }
                }
            })
        }
    }
    
    func setupUI() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        signInButton.layer.cornerRadius = 5
        signInButton.layer.borderWidth = 1
        signInButton.layer.borderColor = UIColor.white.cgColor
        crearUsuarioButton.layer.cornerRadius = 5
        crearUsuarioButton.layer.borderWidth = 1
        crearUsuarioButton.layer.borderColor = UIColor.white.cgColor
        
        logoImageView.layer.borderWidth=1.0
        logoImageView.layer.masksToBounds = false
        logoImageView.layer.borderColor = UIColor.black.cgColor
        logoImageView.layer.cornerRadius = 50
        logoImageView.clipsToBounds = true


    }
    
    @IBAction func forgotPasswordAction(_ sender: AnyObject) {
        checkReachability()
        let alert = UIAlertController(title: "Enviar solicitud", message: "Para resetear su contraseña, porfavor provea su correo de usuario.", preferredStyle: .alert)
        let enviarAction = UIAlertAction(title: "Enviar", style: .default) { action in
            let emailField = alert.textFields![0]
            let emailText = emailField.text!
            
            self.usersRef.queryOrdered(byChild: "email").queryEqual(toValue: emailText).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    FIRAuth.auth()?.sendPasswordReset(withEmail: emailText) {
                        error in
                        
                        if error == nil {
                            let alert = UIAlertController(title: "Solicitud enviada", message: "Su solicitud de cambio de contraseña ha sido enviada. Revise su correo.", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default)
                            
                            alert.addAction(okAction)
                            
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            let alert = UIAlertController(title: "Error", message: "Su solicitud no pudo ser enviada. Porfavor intente mas tarde.", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default)
                            
                            alert.addAction(okAction)
                            
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                } else {
                    let alert = UIAlertController(title: "Usuario no existe", message: "El usuario ingresado no existe.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .default)
        
        alert.addTextField { textEmail in
            textEmail.placeholder = "Correo electrónico"
        }
        
        alert.addAction(enviarAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func signInAction(_ sender: AnyObject) {
        checkReachability()
        if (emailTextField.text?.isEmpty)! {
            let alert = UIAlertController(title: "Campo requerido", message: "Ingrese su correo en el campo provisto.", preferredStyle: .alert)
            let okAlertAction = UIAlertAction(title: "OK", style: .default)
            
            alert.addAction(okAlertAction)
            present(alert, animated: true, completion: nil)
        } else if (passwordTextField.text?.isEmpty)! {
            let alert = UIAlertController(title: "Campo requerido", message: "Ingrese su contraseña en el campo provisto.", preferredStyle: .alert)
            let okAlertAction = UIAlertAction(title: "OK", style: .default)
            
            alert.addAction(okAlertAction)
            present(alert, animated: true, completion: nil)
        } else {
            if isValidEmail(testStr: emailTextField.text!) {
                FIRAuth.auth()?.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) {
                    user, error in
                    
                    if error != nil {
                        let errCode = FIRAuthErrorCode(rawValue: error!._code)
                        
                        switch errCode?.rawValue {
                        case FIRAuthErrorCode.errorCodeWrongPassword.rawValue?:
                            self.errorAlert(flag: 4)
                            break
                        case FIRAuthErrorCode.errorCodeUserNotFound.rawValue?:
                            self.errorAlert(flag: 6)
                            break
                        case FIRAuthErrorCode.errorCodeInvalidEmail.rawValue?:
                            self.errorAlert(flag: 7)
                            break
                        default:
                            break
                        }
                        print(error)
                    }
                }
            } else {
                let alert = UIAlertController(title: "Correo inválido", message: "Ingrese un correo válido.", preferredStyle: .alert)
                let okAlertAction = UIAlertAction(title: "OK", style: .default)
                
                alert.addAction(okAlertAction)
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func createUserAction(_ sender: AnyObject) {
        checkReachability()
        if (emailTextField.text?.isEmpty)! {
            errorAlert(flag: 2)
        } else if (passwordTextField.text?.isEmpty)! {
            errorAlert(flag: 0)
        } else {
            if isValidEmail(testStr: emailTextField.text!) {
                FIRAuth.auth()?.createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { user, error in
                    if error == nil {
                        FIRAuth.auth()!.signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!){
                            user, error in
                                                
                            if error != nil {
                                let errCode = FIRAuthErrorCode(rawValue: error!._code)
                                                    
                                switch errCode?.rawValue {
                                case FIRAuthErrorCode.errorCodeWrongPassword.rawValue?:
                                    self.errorAlert(flag: 4)
                                    break
                                case FIRAuthErrorCode.errorCodeUserNotFound.rawValue?:
                                    self.errorAlert(flag: 6)
                                    break
                                default:
                                    break
                                }
                                print(error)
                            }
                        }
                    } else {
                        let errCode = FIRAuthErrorCode(rawValue: error!._code)

                        switch errCode?.rawValue {
                        case FIRAuthErrorCode.errorCodeWeakPassword.rawValue?:
                            self.errorAlert(flag: 1)
                            break
                        case FIRAuthErrorCode.errorCodeEmailAlreadyInUse.rawValue?:
                            self.errorAlert(flag: 5)
                            break
                        default:
                            break
                        }
                    }
                }
            } else {
                errorAlert(flag: 3)
            }
        }
    }
    
    func userExists(email: String) -> Bool {
        
        self.usersRef.queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value, with: { (snapshot) in
            return snapshot.exists()
        }) { (error) in
            print(error.localizedDescription)
        }
        return false
    }
    
    func errorAlert(flag: Int) {
        var message: String!
        var titulo: String!
        switch flag {
        case 0:
            titulo = "Campo requerido"
            message = "Ingrese su contraseña el campo provisto."
            break
        case 1:
            titulo = "Contraseña insegura"
            message = "Porfavor provea una contraseña mas segura. Utilice 6 o más caracteres."
            break
        case 2:
            titulo = "Campo requerido"
            message = "Ingrese su correo en el campo provisto."
            break
        case 3:
            titulo = "Error"
            message = "Ingrese un correo valido."
            break
        case 4:
            titulo = "Contraseña incorrecta"
            message = "La contraseña es incorrecta."
            break
        case 5:
            titulo = "Error"
            message = "Ya existe una cuenta asociada con este correo. Porfavor utilice un correo diferente."
        case 6:
            titulo = "Usuario no existe"
            message = "No existe una cuenta asociada con este correo. Porfavor cree una cuenta nueva."
        case 7:
            titulo = "Correo inválido"
            message = "Porfavor ingrese un correo válido."
        default:
            break
        }
        let alert = UIAlertController(title: titulo, message: message, preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAlertAction)
        present(alert, animated: true, completion: nil)
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    
    //MARK: Keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        if textField == passwordTextField {
            textField.resignFirstResponder()
            self.view.endEditing(true)
        }
        return true
    }
    
    func subscribeToKeyboardNotificationShow() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func subscribeToKeyboardNotificationHide() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func adjustInsetForKeyboardShow(show: Bool, notification: NSNotification) {
        guard let value = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue else { return }
        let keyboardFrame = value.cgRectValue
        
        var variableHeight: CGFloat = 0.0
        if UIDevice.current.orientation.isLandscape {
            variableHeight = 100
        } else {
            variableHeight = 50
        }
        
        let adjustmentHeight = (keyboardFrame.height - variableHeight) * (show ? 1 : -1)
        if keyboardIsShowing != show {
            self.view.frame.origin.y -= adjustmentHeight
        }
            
        if !show {
            self.view.frame.origin.y = 0
        }
        scrollView.scrollIndicatorInsets.bottom += adjustmentHeight
    }
    
    func keyboardWillShow(notification: NSNotification) {
        adjustInsetForKeyboardShow(show: true, notification: notification)
        keyboardIsShowing = true
    }
    
    func keyboardWillHide(notification: NSNotification) {
        adjustInsetForKeyboardShow(show: false, notification: notification)
        keyboardIsShowing = false
    }
}
