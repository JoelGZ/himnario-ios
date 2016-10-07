//
//  LoginViewController.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 10/6/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var crearUsuarioButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        FIRAuth.auth()?.addStateDidChangeListener() {auth, user in
            if user != nil {
                self.performSegue(withIdentifier: "loggedInSegue", sender: nil)
            }
        }
    }
    
    func setupUI() {
        signInButton.layer.cornerRadius = 5
        signInButton.layer.borderWidth = 1
        signInButton.layer.borderColor = UIColor.white.cgColor
        crearUsuarioButton.layer.cornerRadius = 5
        crearUsuarioButton.layer.borderWidth = 1
        crearUsuarioButton.layer.borderColor = UIColor.white.cgColor
        logoImageView.layer.cornerRadius = logoImageView.frame.size.width / 2

    }
    @IBAction func signInAction(_ sender: AnyObject) {
        
        if (emailTextField.text?.isEmpty)! {
            
            //check if user exists
            let alert = UIAlertController(title: "Campo requerido", message: "Ingrese su correo en el campo provisto.", preferredStyle: .alert)
            let okAlertAction = UIAlertAction(title: "OK", style: .default)
            
            alert.addAction(okAlertAction)
            present(alert, animated: true, completion: nil)
        } else if (passwordTextField.text?.isEmpty)! {
            //check if pasword is correct
            let alert = UIAlertController(title: "Campo requerido", message: "Ingrese su contraseña en el campo provisto.", preferredStyle: .alert)
            let okAlertAction = UIAlertAction(title: "OK", style: .default)
            
            alert.addAction(okAlertAction)
            present(alert, animated: true, completion: nil)
        } else {
            if isValidEmail(testStr: emailTextField.text!) {
                FIRAuth.auth()?.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!)
            } else {
                let alert = UIAlertController(title: "Email invalido", message: "Ingrese un correo valido.", preferredStyle: .alert)
                let okAlertAction = UIAlertAction(title: "OK", style: .default)
                
                alert.addAction(okAlertAction)
                present(alert, animated: true, completion: nil)
            }
        }

    }
    
    @IBAction func createUserAction(_ sender: AnyObject) {
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
                FIRAuth.auth()?.createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { user, error in
                    if error == nil {
                        FIRAuth.auth()!.signIn(withEmail: self.emailTextField.text!,
                                               password: self.passwordTextField.text!)
                        self.performSegue(withIdentifier: "loggedInSegue", sender: nil)
                    }
                }
            } else {
                let alert = UIAlertController(title: "Email invalido", message: "Ingrese un correo valido.", preferredStyle: .alert)
                let okAlertAction = UIAlertAction(title: "OK", style: .default)
                
                alert.addAction(okAlertAction)
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        if textField == passwordTextField {
            textField.resignFirstResponder()
        }
        return true
    }
    
}
