//
//  NewListViewController.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 10/17/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import UIKit

class NewListViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var customizeButton: UIButton!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var customizedNameTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var keyboardIsUp:Bool = false
    
    var databaseManager: DatabaseManager = DatabaseManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.subscribeToKeyboardNotificationShow()
        self.subscribeToKeyboardNotificationHide()
        
        
        // TODO: localize strings
        instructionsLabel.text = "Elija la fecha para nombrar la lista o personalice el nombre de la lista."
        customizeButton.setTitle("Personalizar", for: .normal)
        
        //Set minimum date to current date
        datePicker.minimumDate = NSDate() as Date
        scrollView.contentSize.width = 0
        if UIDevice.current.orientation.isPortrait {
            scrollView.contentSize.height = view.frame.height
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchCorosForList" {
            
            var nameOfList:String?
            let customizedName = customizedNameTextField.text
            
            if (customizedName!.isEmpty || customizedName == "") {
                
                let dayTimePeriodFormatter = DateFormatter()
                dayTimePeriodFormatter.dateFormat = "MMMM d"
                let dateString = dayTimePeriodFormatter.string(from: datePicker.date)
                nameOfList = dateString.capitalized
                print(datePicker.date)
                
            } else {
                nameOfList = customizedName?.capitalized
            }
            
            //Create row list
            let archivoNameString = "Lista_\(nameOfList!)"
          //  let newRowId = databaseManager.createNuevaLista(nameOfList!, nombreArchivo: archivoNameString)
            print("printing newrowid: \(newRowId)")
            print(nameOfList)
            print(archivoNameString)
            
            //destination VC setup
            if let destination = segue.destinationViewController as? SelectCorosForListViewController {
                destination.listId = newRowId
            }
        }

    }
      // keyboard is dismissed with return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func customizeNameOfList(sender: AnyObject) {
        
        self.customizedNameTextField.delegate = self
        customizedNameTextField.isHidden = true
        
        
        customizedNameTextField.placeholder = "Nombre Personalizado"
        customizedNameTextField.isHidden = false
        
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
    
    func keyboardWillShow(notification: NSNotification) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            if keyboardIsUp == false {
                if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                    self.view.frame.origin.y -= keyboardSize.height
                    keyboardIsUp = true
                }
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            if keyboardIsUp == true {
                if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                    self.view.frame.origin.y += keyboardSize.height
                    keyboardIsUp = false
                }
            }
        }
        
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        print (keyboardSize.cgRectValue.height)
        return keyboardSize.cgRectValue.height
    }
    
}

