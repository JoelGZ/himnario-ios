//
//  AjustesViewController.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 10/7/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import UIKit
import MessageUI
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class AjustesTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var signInOutLabel: UILabel!
    
    let APP_ID = "1118729781"
    override func viewDidLoad() {
        super.viewDidLoad()
        
      //  activityIndicator.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func rateAppAlert() {
        let alert = UIAlertController(title: "Califica la aplicación", message: "Si esta aplicación ha sido de bendición para usted le agradeceriamos si puede calificarla favorablemente.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let rateAction = UIAlertAction(title: "Ir a Itunes", style: .default, handler: {(alert : UIAlertAction!) -> Void in self.rateApp()})
        alert.addAction(cancelAction)
        alert.addAction(rateAction)
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = self.view.bounds
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func rateApp() {
        let rateString = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(APP_ID)&onlyLatestVersion=true&pageNumber=0&sortOrdering=1)"
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(NSURL(string: rateString)! as URL)
        } else {
            UIApplication.shared.openURL(NSURL(string : rateString)! as URL)
        }
    }
    
    func reportProblem() {
        let mailVC = configurarCorreoVC(message: "", recipients: ["innovate.appsjgz@gmail.com"], subject: "Problema con Aplicación")
        
        if MFMailComposeViewController.canSendMail() {
            self.present(mailVC, animated: true, completion: nil)
        } else {
            self.showAlertErrorWithEmail()
        }
    }
    
    func contactUs() {
        let mailVC = configurarCorreoVC(message: "", recipients: ["innovate.appsjgz@gmail.com"], subject: "")
        
        if MFMailComposeViewController.canSendMail() {
            self.present(mailVC, animated: true, completion: nil)
        } else {
            self.showAlertErrorWithEmail()
        }
    }
    
    func downloadPartituras() {
        // tengo que ver que hacer cuando se interrumpe la senal de internet
        // tengo que ver q hacer cuando se agreguen nuevos coros
        // podria hacer algo como que cuando se agregue un coro nuevo en firebase que en el app al abrirla salga un mensaje preguntando si se desea descargar la partitura. 
        
        let storage = FIRStorage.storage()
        let corosRef = FIRDatabase.database().reference().child("coros")
        corosRef.observe(FIRDataEventType.value, with: {(snapshot) in
            for coroRef in snapshot.children {
                
            }
        })
        let coroPartituraRef = storage.reference(forURL: "https://firebasestorage.googleapis.com/v0/b/alabadle-con-entendimiento.appspot.com/o/partituras%2Fa_cristo_coronad.jpg?alt=media&token=5f19e55f-b1d4-44bc-a370-92912f8d7ab7")
        
        // Create local filesystem URL
        let localURL = getDocumentsDirectory().appendingPathComponent("a_cristo_coronad.jpg")

        // Download to the local filesystem
        let downloadTask = coroPartituraRef.write(toFile: localURL) { url, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print(error)
            } else {
                print(url)
                // Local file URL for "images/island.jpg" is returned
            }
        }
        let observer = downloadTask.observe(.progress) {snapshot in
            print(snapshot.status.rawValue)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func signInOut() {
        if signInOutLabel.text! == "Salir" {
            try! FIRAuth.auth()?.signOut()
            
            let alert = UIAlertController(title: "Éxito", message: "Ha salido con exito. Para visualizar sus listas es necesario que vuelva a ingresar.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            
            signInOutLabel.text = "Iniciar sesión"
        } else {
            self.navigationController?.isNavigationBarHidden = true
            self.tabBarController?.tabBar.isHidden = true
            performSegue(withIdentifier: "goToLogScreenSegue", sender: nil)
        }
        
    }
    
    func changePassword() {
        let defaults = UserDefaults.standard
        let userEmail = defaults.value(forKey: "USER_EMAIL") as! String
        
        FIRAuth.auth()?.sendPasswordReset(withEmail: userEmail) {
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
    }
    
    func configurarCorreoVC(message: String, recipients: [String], subject: String) -> MFMailComposeViewController {
        let mailComposerViewController = MFMailComposeViewController()
        mailComposerViewController.mailComposeDelegate = self
        
        mailComposerViewController.setToRecipients(recipients)
        mailComposerViewController.setMessageBody(message, isHTML: false)
        mailComposerViewController.setSubject(subject)
        return mailComposerViewController
    }
    
    func showAlertErrorWithEmail() {
        let alert = UIAlertController(title: "Error!", message: "Su dispositivo no pudo enviar el correo. Porfavor Revise las configuraciones de su correo e intentelo de nuevo.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 2
        case 2:
            return 2
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let url = NSURL(string: "https://innovateideasjg.wordpress.com/tutoriales/")
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url! as URL)
                } else {
                    UIApplication.shared.openURL(url! as URL)
                }
            case 1:
                downloadPartituras()
                break
            default:
                break
            }
            break
        case 1:
            switch indexPath.row {
            case 0:
                signInOut()
                break;
            case 1:
                changePassword()
                break;
            default:
                break;
            }
            break
        case 2:
            switch indexPath.row {
            case 0:
                reportProblem()
                break;
            case 1:
                contactUs()
                break;
            default:
                break;
            }
            /* case 0:
             rateAppAlert()
             break;
             case 1:
             reportProblem()
             break;
             case 2:
             contactUs()
             break;
             default:
             break;
             }*/
            break
        default:
            break
        }
    
        self.tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
}



