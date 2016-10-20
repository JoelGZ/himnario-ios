//
//  ListasTableViewController.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 10/11/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

protocol ListaSelectionDelegate: class {
    func listaSelected(newLista: Lista)
}

class ListasTableViewController: UITableViewController {
    
    @IBOutlet weak var navBar: UINavigationItem!
    var resultArray: Array<Lista> = []
    var resultNumber: Int?
    var noListView: UIView?
    var label: UILabel?
    var flag = false
    var detailViewController: DetailListViewController?
    
    let rootRef = FIRDatabase.database().reference()
    var listasDeUsuarioRef: FIRDatabaseReference!
    
    weak var delegate: ListaSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        listasDeUsuarioRef = rootRef.child("listas/\(defaults.string(forKey: "USER_UID")!)")
        // TODO: localize
        navBar.title = "Mis Listas"
        flag = true
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailListViewController
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil {
                self.loadListasData()
            } else {
                let alert = UIAlertController(title: "Inicie sesión", message: "Para poder visualizar sus listas, por favor inicie sesión.", preferredStyle: .alert)
                let inicarSesionAction = UIAlertAction(title: "Iniciar sesión", style: .default, handler: {_ in
                    self.navigationController?.navigationBar.isHidden = true
                    //TODO: do not permit to go back
                    self.performSegue(withIdentifier: "goToLogInScreen", sender: nil)
                })
                alert.addAction(inicarSesionAction)
                
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        
        self.tabBarController?.tabBar.isHidden = false
        
    }
    
    func loadListasData(){
        var childrenCounter = 0
        listasDeUsuarioRef.observeSingleEvent(of: FIRDataEventType.value, with: {(snapshot) in
            var tempArray = [Lista]()

            for listaID in snapshot.children {
                let listaIDStr = "\((listaID as! FIRDataSnapshot).key)"
                let listaRef = self.listasDeUsuarioRef.child(listaIDStr)
                listaRef.observeSingleEvent(of: FIRDataEventType.value, with: {(snapshotChild) in
                    childrenCounter += 1
                    let lista = Lista(snapshot: snapshotChild, dbRef: listaRef)
                    tempArray.append(lista)
                    if childrenCounter == Int(snapshot.childrenCount) {
                        self.resultArray = tempArray
                        self.tableView.reloadData()
                    }
                })
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addList" {
            flag = false
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ListaTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ListaTableViewCell
        
        let lista = resultArray[indexPath.row]
        cell.nombreListaLabel.text = lista.nombreLista
        cell.tonalidadListaLabel.text = lista.ton_global
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lista = self.resultArray[indexPath.row]
        self.delegate?.listaSelected(newLista: lista)
        
        //FIX ERROR: when user signs out, and then signs in thru listastvc it later does not go into the list.
        //Also when signs out and going back to lists it reveals detail vc instead of master vc first
        //***********************
        
        if let detailViewController = self.delegate as? DetailListViewController {
            detailViewController.lista = lista
            detailViewController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            detailViewController.navigationItem.leftItemsSupplementBackButton = true
            
            let screenSize: CGRect = UIScreen.main.bounds
            let screenWidth = screenSize.width
            let screenHeigth = screenSize.height
            let maxScreenMeasurement = max(screenWidth, screenHeigth)
            if maxScreenMeasurement <= 736 {
                splitViewController?.showDetailViewController(detailViewController.navigationController!, sender: nil)
            }
        }

    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let lista = self.resultArray[indexPath.row]
          //  databaseManager?.deleteLista(lista._id)
            resultArray.remove(at: indexPath.row)
            if indexPath.row != 0 {
                self.delegate?.listaSelected(newLista: resultArray[indexPath.row - 1])
            } else {
                self.detailViewController?.setupNoListView()
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            if resultArray.count == 0 {
                if let detailViewController = self.delegate as? DetailListViewController{
                    detailViewController.lista = Lista(id: 10000, nombreLista: "", ton_global: "", ton_rap: "", ton_lent: "")
                    detailViewController.setupNoListView()
                }
            }
        }

    }
}

