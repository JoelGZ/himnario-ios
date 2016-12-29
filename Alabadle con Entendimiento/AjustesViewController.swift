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
    
    @IBOutlet weak var downloadProgressLabel: UILabel!
    @IBOutlet weak var descargaLabel: UILabel!
    @IBOutlet weak var signInOutLabel: UILabel!
    
    let APP_ID = "1118729781"
    var progressPercentage: Double?
    var downloadDeleteFlag: Bool = true    //true= can download; false = can't download, just delete
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      //  activityIndicator.isHidden = true
        if progressPercentage != nil {
            downloadProgressLabel.text = "\(Int(progressPercentage!))"
        }
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
        var corosCont = 0.0
        downloadProgressLabel.text = "0%"
        downloadProgressLabel.isHidden = false
        
        let storage = FIRStorage.storage()
        let corosRef = FIRDatabase.database().reference().child("coros")
        corosRef.observe(FIRDataEventType.value, with: {(snapshot) in
            let cantCoros = Double(snapshot.childrenCount)
            for coroSnap in snapshot.children {
                let coro = Coro(snapshot: coroSnap as! FIRDataSnapshot, coroId: Int((coroSnap as AnyObject).key)!)
                let coroPartituraRef = storage.reference(forURL: coro.partitura)
                let sName = coro.sName
                let musicaString = sName.replacingOccurrences(of: " ", with:"_")                            
                
                // Create local filesystem URL
                let localURL = self.getDocumentsDirectory().appendingPathComponent("partitura/\(musicaString).jpg")
                
                // Download to the local filesystem
                _ = coroPartituraRef.write(toFile: localURL) { url, error in
                    if let error = error {
                        let alert = UIAlertController(title: "Error", message: "Hubo un error en la descarga. Por favor, intentelo nuevamente. Si el problema persiste no dude en contactarnos.", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        print(error)
                    } else {
                        corosCont += 1
                        self.progressPercentage = (corosCont/cantCoros) * 100
                        self.downloadProgressLabel.text = "\(Int(self.progressPercentage!))%"
                        if corosCont == cantCoros {
                            let alert = UIAlertController(title: "Descarga completa", message: "La descarga ha sido completada.", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
                            self.downloadProgressLabel.isHidden = true
                            self.descargaLabel.text = "Eliminar partituras descargadas"
                        }
                    }
                }
            }
        })
        
        downloadDeleteFlag = false
    }
    
    func deletePartiturasInMemory() {
        var partituraURLsArray: Array<URL> = []
        let corosRef = FIRDatabase.database().reference().child("coros")
        corosRef.observe(FIRDataEventType.value, with: {(snapshot) in
            for coroSnap in snapshot.children {
                let coro = Coro(snapshot: coroSnap as! FIRDataSnapshot, coroId: Int((coroSnap as AnyObject).key)!)
                let sName = coro.sName
                let musicaString = sName.replacingOccurrences(of: " ", with:"_")
                
                // Create local filesystem URL
                let localURL = self.getDocumentsDirectory().appendingPathComponent("partitura/\(musicaString).jpg")
                
                partituraURLsArray.append(localURL)
            }
            for url in partituraURLsArray {
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {
                    print("No se pudo eliminar la partitura con url: \(url)")
                }
            }
        })
        
        
        descargaLabel.text = "Descarga de partituras"
        downloadDeleteFlag = true
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
                var message = ""
                if downloadDeleteFlag {
                    message = "Al descargar las partituras podrá accesarlas sin conexión de internet."
                    let alert = UIAlertController(title: "¡Atención!", message: message, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: {(alert : UIAlertAction!) -> Void in self.downloadPartituras()})
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    alert.addAction(okAction)
                    alert.addAction(cancelAction)
                    present(alert, animated: true, completion: nil)
                } else {
                    message = "¿Desea eliminar totalmente las partituras?"
                    let alert = UIAlertController(title: "¡Atención!", message: message, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: {(alert : UIAlertAction!) -> Void in self.deletePartiturasInMemory()})
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    alert.addAction(okAction)
                    alert.addAction(cancelAction)
                    present(alert, animated: true, completion: nil)
                }
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



