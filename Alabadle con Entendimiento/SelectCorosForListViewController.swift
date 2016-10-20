//
//  SelectCorosForListViewController.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 10/18/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SelectCorosForListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UISearchControllerDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rapidosButton: VelButton!
    @IBOutlet weak var mediosButton: VelButton!
    @IBOutlet weak var lentosButton: VelButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var toolBar: UIToolbar!
    
    // MARK: Properties
    var corosArray: Array<Coro>?
    var safeCoros = [Int]()
    var filteredCorosArray: Array<Coro>?
    let searchController = UISearchController(searchResultsController: nil)
    var velocidadDic: [String: Bool] = ["R": false, "M": false , "L": false]
    var keyboardIsUp:Bool = false
    var listId: Int!
    var scope: String = "Todos"
    var coroIndex: Int?
    
    let rootRef = FIRDatabase.database().reference()
    var corosRef: FIRDatabaseReference!
    var safeCorosRef: FIRDatabaseReference!
    var listaRef: FIRDatabaseReference!
    var isSafeToDisplayFlag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        corosRef = rootRef.child("coros")
        let defaults = UserDefaults.standard
        isSafeToDisplayFlag = defaults.bool(forKey: "SAFE")
        print("Pring: \(isSafeToDisplayFlag)")
        if (isSafeToDisplayFlag) {
            loadData()
        } else {
            loadSafeData()
        }
        
        // Keyboard subscriptions
        self.subscribeToKeyboardNotificationShow()
        self.subscribeToKeyboardNotificationHide()
        
        setupSearchController()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        navigationItem.hidesBackButton = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        let app = UIApplication.shared
        if searchController.isActive && !app.isStatusBarHidden && searchController.searchBar.frame.origin.y == 0 {
            if let container = self.searchController.searchBar.superview {
           //     container.frame = CGRectMake(container.frame.origin.x, container.frame.origin.y, container.frame.size.width, container.frame.size.height + app.statusBarFrame.height)
            }
        }
    }
    
    func loadData() {
        corosRef.observe(FIRDataEventType.value, with: {(snapshot) in
            var tempCoroArray = [Coro]()
            
            for coroSnap in snapshot.children {
                let coro = Coro(snapshot: coroSnap as! FIRDataSnapshot, dbRef: self.corosRef)
                tempCoroArray.append(coro)
            }
            
            self.corosArray = tempCoroArray
            self.tableView.reloadData()
        })
    }
    
    func loadSafeData() {
        var tempCoroArray2 = [Coro]()
        safeCorosRef = rootRef.child("safeCoros")
        safeCorosRef.observe(FIRDataEventType.value, with: {(snapshot) in
            for coroSnap in snapshot.children {
                let coroId = (coroSnap as! FIRDataSnapshot).value
                self.safeCoros.append(coroId as! Int)
            }
            
            for coroId in self.safeCoros {
                let coroRef = self.corosRef.child(String(coroId))
                
                coroRef.observe(FIRDataEventType.value, with: {(sp) in
                    // print(sp.value)
                    let coro = Coro(snapshot: sp, coroId: coroId)
                    tempCoroArray2.append(coro)
                    if tempCoroArray2.count == self.safeCoros.count {
                        self.corosArray = tempCoroArray2
                        self.tableView.reloadData()
                    }
                })
            }
        })
    }

    
    // MARK: Velocidad Button actions
    // the if condition is apparently backwards but it is done this way because this is executed before isChecked is changed in the Checkbox object
    @IBAction func rapidosChecked(sender: AnyObject) {
        if rapidosButton.isChecked {
            velocidadDic["R"] = false
        } else {
            velocidadDic["R"] = true
        }
        updateSearchResults(for: searchController)
        searchController.isActive = true
    }
    
    @IBAction func mediosChecked(sender: AnyObject) {
        if mediosButton.isChecked {
            velocidadDic["M"] = false
        } else {
            velocidadDic["M"] = true
        }
        updateSearchResults(for: searchController)
        searchController.isActive = true
    }
    
    @IBAction func lentosChecked(sender: AnyObject) {
        if lentosButton.isChecked {
            velocidadDic["L"] = false
        } else {
            velocidadDic["L"] = true
        }
        updateSearchResults(for: searchController)
        searchController.isActive = true
    }
    
    @IBAction func tonalidadFilterAction(sender: UISegmentedControl) {
        print("executing")
        let index = sender.selectedSegmentIndex
        if index == 0 {
            scope = "Todos"
        } else {
            scope = sender.titleForSegment(at: index)!
        }
        updateSearchResults(for: searchController)
        searchController.isActive = true
    }
    
    // MARK: search properties
    func setupSearchController() {
        // search controller setup
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Busqueda"
        searchController.hidesNavigationBarDuringPresentation = false
        self.navigationItem.titleView = self.searchController.searchBar
        searchController.delegate = self
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "Todos") {
        var contVel = 0
        var velValuesArray: Array<String> = []
        for (velValue, velBool) in velocidadDic {
            if velBool {
                velValuesArray.append(velValue)
                contVel += 1
            }
        }
        
        switch (contVel) {
        case 1:
            filteredCorosArray = corosArray!.filter { coro in
                let tonMatch = (scope == "Todos") || (coro.tonalidad == scope.getReadableText()) || (coro.ton_alt == scope.getReadableText())
                if searchText != "" {
                    //buscar nombre y searchableName
                    return coro.velletra.contains(velValuesArray[0]) && tonMatch && (coro.nombre.lowercased().contains(searchText.lowercased()) || coro.sName.lowercased().contains(searchText.lowercased()))

                } else {
                    return tonMatch && coro.velletra.contains(velValuesArray[0])
                }
            }
            break;
        case 2:
            let filterArray1: Array<Coro> = corosArray!.filter { coro in
                let tonMatch = (scope == "Todos") || (coro.tonalidad == scope.getReadableText()) || (coro.ton_alt == scope.getReadableText())
                if searchText != "" {
                    //buscar nombre y searchableName
                    return coro.velletra.contains(velValuesArray[0]) && tonMatch && (coro.nombre.lowercased().contains(searchText.lowercased()) || coro.sName.lowercased().contains(searchText.lowercased()))
                } else {
                    return tonMatch && coro.velletra.contains(velValuesArray[0])
                }
            }
            
            let filterArray2: Array<Coro> = corosArray!.filter { coro in
                let tonMatch = (scope == "Todos") || (coro.tonalidad == scope.getReadableText()) || (coro.ton_alt == scope.getReadableText())
                if searchText != "" {
                    //buscar nombre y searchableName
                    return coro.velletra.contains(velValuesArray[1]) && tonMatch && (coro.nombre.lowercased().contains(searchText.lowercased()) || coro.sName.lowercased().contains(searchText.lowercased()))
                } else {
                    return tonMatch && coro.velletra.contains(velValuesArray[1])
                }
            }
            
            filteredCorosArray = filterArray1 + filterArray2.filter { coro in
                return !filterArray1.contains(coro)
            }
            break;
        default:
            // agregar columna en base de datos "searchableName" que tenga el nombre sin tildes.
            filteredCorosArray = corosArray!.filter { coro in
                let tonMatch = (scope == "Todos") || (coro.tonalidad == scope.getReadableText()) || (coro.ton_alt == scope.getReadableText())
                if searchText != "" {
                    //buscar nombre y searchableName
                    return tonMatch && (coro.nombre.lowercased().contains(searchText.lowercased()) || coro.sName.lowercased().contains(searchText.lowercased()))
                } else {
                    return tonMatch
                }
            }
            break;
        }
        
        tableView.reloadData()
    }
    
    @IBAction func doneChoosingSongs(unwindSegue: UIStoryboardSegue) {
        navigationController?.popToRootViewController(animated: false)
        //hice algo con un unwindsegue exit en storyboard
    }
    
    func corosActions(index: Int) {
    /*    var coro: Coro?
        if searchController.isActive {
            coro = filteredCorosArray![index]
        } else {
            coro = corosArray![index]
        }
        
        databaseManager.isCoroEnLista(listId, coroId: coro!._id)
        
        if databaseManager.isCoroEnLista(listId, coroId: coro!._id) {
            databaseManager.deleteCoroEnLista(listId, coroId: coro!._id, flag: true)
        } else {
            databaseManager.agregarCoroALista(listId, coroId: coro!._id)
        }
        tableView.reloadData()*/
    }
    
    // MARK: table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return filteredCorosArray!.count
        } else {
            return corosArray!.count
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let showDetail = UITableViewRowAction(style: .normal, title: "Detalle") { action, index in
            self.coroIndex = indexPath.row
            self.performSegue(withIdentifier: "showCoroDetail", sender: nil)
        }
        showDetail.backgroundColor = UIColor.blue
        
        
        return [showDetail]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var coro: Coro
        if searchController.isActive {
            coro = filteredCorosArray![indexPath.row]
        } else {
            coro = corosArray![indexPath.row]
        }
        
        let corosEnListaRef = listaRef.child("corosEnLista")
        corosEnListaRef.observeSingleEvent(of: FIRDataEventType.value, with: {(snapshot) in
            let coroRef = corosEnListaRef.child("\(coro.id)")
            if snapshot.hasChild("\(coro.id)") {
                //delete coro
                coroRef.removeValue()
            } else {
                //add coro
                //coroRef.setValue()
            }
            tableView.reloadData()
        })
        databaseManager.isCoroEnLista(listId, coroId: coro!._id)
        
        if databaseManager.isCoroEnLista(listId, coroId: coro!._id) {
            databaseManager.deleteCoroEnLista(listId, coroId: coro!._id, flag: true)
        } else {
            databaseManager.agregarCoroALista(listId, coroId: coro!._id)
        }
        tableView.reloadData()
    }
    
    func setupCoroForList(coro: Coro) -> Any {
        
        
        
        return [
            "nombre": coro.nombre,
            "orden": 000,
            "ton": coro.tonalidad,
            "vel_let": coro.velletra
        ]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SelectCorosForListTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SelectCorosForListTableViewCell
        
        var coro: Coro?
        if searchController.isActive {
            coro = filteredCorosArray![indexPath.row]
        } else {
            coro = corosArray![indexPath.row]
        }
        
        
      /*  // Checkmark or Disclosure
        if databaseManager.isCoroEnLista(listId, coroId: coro!._id) {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        }*/
        
        
        //Fill table with data
        cell.nombreCoroLabel.text = coro!.nombre
        if searchController.isActive && scope != "Todos" {
            if coro!.ton_alt != "" {
                cell.tonalidadLabel.text = "\(coro!.tonalidad),\(coro!.ton_alt)"
            } else {
                cell.tonalidadLabel.text = coro!.tonalidad
            }
        } else {
            cell.tonalidadLabel.text = coro!.tonalidad
        }
        cell.velocidadLabel.text = coro!.velletra.getReadableText()
        
        return cell

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       /* if segue.identifier == "doneChoosingCoros" {
            //MAY NOT NEED
            let destinationVC = segue.destination as? DetailListViewController
            let lista = databaseManager.getLista(listId)
            destinationVC!.lista = lista
            // hide current tab bar to show other tab bar
            self.tabBarController?.tabBar.isHidden = true
        } else if segue.identifier == "showCoroDetail" {
            let tabBarController = segue.destination as? UITabBarController
            let destinationVC = tabBarController?.viewControllers?.first as? CoroDetailViewController
            let secondVC = tabBarController?.viewControllers?.last as? MusicaViewController
            
            var coro: Coro!
            if searchController.isActive {
                coro = filteredCorosArray![coroIndex!]
            } else {
                coro = corosArray![coroIndex!]
            }
            destinationVC!.coro = coro
            //para la partitura
            secondVC!.coro = coro
            secondVC!.vc = 3
            navigationItem.title = nil
            
            // hide current tab bar to show other tab bar
            self.tabBarController?.tabBar.isHidden = true
        }
*/
    }
    
    //Keyboard
    
    // keyboard is dismissed with return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
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
    
    func keyboardWillShow(notification: NSNotification) {}
    
    func keyboardWillHide(notification: NSNotification) {}

}

extension SelectCorosForListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: scope)
    }
}

extension SelectCorosForListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchText: searchBar.text!, scope: scope)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        rapidosButton.isChecked = false
        mediosButton.isChecked = false
        lentosButton.isChecked = false
        segmentedControl.selectedSegmentIndex = 0
    }
}
