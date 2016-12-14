//
//  CorosTableViewController.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 10/4/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class CorosTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UISearchControllerDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rapidosButton: VelButton!
    @IBOutlet weak var mediosButton: VelButton!
    @IBOutlet weak var lentosButton: VelButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // MARK: Properties
    var scope: String = "Todos"
    var corosArray: Array<Coro>?
    var safeCoros = [Int]()
    var user: User!
    var filteredCorosArray: Array<Coro>?
    let searchController = UISearchController(searchResultsController: nil)
    var velocidadDic: [String: Bool] = ["R": false, "M": false , "L": false]
    
    let rootRef = FIRDatabase.database().reference()
    var corosRef: FIRDatabaseReference!
    var safeCorosRef: FIRDatabaseReference!
    var isSafeToDisplayFlag = false      /// change this later to FALSE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        corosRef = rootRef.child("coros")
        
        // Keyboard subscriptions
        self.subscribeToKeyboardNotificationShow()
        self.subscribeToKeyboardNotificationHide()
        
        setupSearchController()
        
        let defaults = UserDefaults.standard
        let tabBarHeight = tabBarController!.tabBar.bounds.height
        defaults.set(Int(tabBarHeight), forKey: "tabBarHeight")
        
        loadFakeData()
        FIRAuth.auth()!.addStateDidChangeListener { auth, FIRuser in
            if FIRuser == nil {        //not signed in
                self.performSegue(withIdentifier: "logInScreenSegue", sender: nil)
            } else {
                let user = User(authData: FIRuser!)
                if user.email == "test@nomail.com" {
                    self.loadSafeData()
                } else {
                    self.loadData()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.unsubscribeFromKeyboardNotifications()
        //REMOVE ALL OBSERVERS or do observesingle...
    }
    
    func loadData() {
        corosRef.queryOrdered(byChild: "orden").observe(FIRDataEventType.value, with: {(snapshot) in
            var tempCoroArray = [Coro]()
            
            for coroSnap in snapshot.children {
                let coro = Coro(snapshot: coroSnap as! FIRDataSnapshot, coroId: Int((coroSnap as AnyObject).key)!)
                tempCoroArray.append(coro)
            }
            
            self.corosArray = tempCoroArray
            self.tableView.reloadData()
        })
        
        loadFakeData()
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
                    let coro = Coro(snapshot: sp, coroId: coroId)
                    tempCoroArray2.append(coro)
                    if tempCoroArray2.count == self.safeCoros.count {
                        self.corosArray = tempCoroArray2
                        for coro in self.corosArray! {
                            print("\(coro.nombre)\n")
                        }
                        self.tableView.reloadData()
                    }
                })
            }
        })
        
        loadFakeData()
    }
    
    func loadFakeData() {
        let coro = Coro(id: 1, orden: 1, nombre: "", cuerpo: "", tonalidad: "", ton_alt: "", velletra: "", tiempo: 1, audio: "", partitura: "", autormusica: "", autorletra: "", cita: "", historia: "", sName: "")
        corosArray = [coro]
    }
    
    // MARK: Velocidad Button actions
    // the if condition is apparently backwards but it is done this way because this is executed before isChecked is changed in the VelButton
    @IBAction func rapidosChecked(sender: AnyObject) {
        if rapidosButton.isChecked {
            velocidadDic["R"] = false
            updateSearchResults(for: searchController)
        } else {
            velocidadDic["R"] = true
            updateSearchResults(for: searchController)
        }
        searchController.isActive = true
        
        
    }
    
    @IBAction func mediosChecked(sender: AnyObject) {
        if mediosButton.isChecked {
            velocidadDic["M"] = false
            updateSearchResults(for: searchController)
        } else {
            velocidadDic["M"] = true
            updateSearchResults(for: searchController)
        }
        searchController.isActive = true
    }
    
    @IBAction func lentosChecked(sender: AnyObject) {
        if lentosButton.isChecked {
            velocidadDic["L"] = false
            updateSearchResults(for: searchController)
        } else {
            velocidadDic["L"] = true
            updateSearchResults(for: searchController)
        }
        searchController.isActive = true
    }
    
    @IBAction func tonalidadFilter(sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        if index == 0 {
            scope = "Todos"
        } else {
            scope = sender.titleForSegment(at: index)!
        }
        updateSearchResults(for: searchController)
        searchController.isActive = true
    }
    //MARK: Other functions
    //search properties
    func setupSearchController() {
        
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
                    return coro.velletra.contains(velValuesArray[0]) && tonMatch && (coro.nombre.lowercased().contains(searchText.lowercased()) || coro.sName.lowercased().contains(searchText.lowercased()))
                } else {
                    return tonMatch && coro.velletra.contains(velValuesArray[0])
                }
            }
            
            let filterArray2: Array<Coro> = corosArray!.filter { coro in
                let tonMatch = (scope == "Todos") || (coro.tonalidad == scope.getReadableText()) || (coro.ton_alt == scope.getReadableText())
                if searchText != "" {
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
            filteredCorosArray = corosArray!.filter { coro in
                let tonMatch = (scope == "Todos") || (coro.tonalidad == scope.getReadableText()) || (coro.ton_alt == scope.getReadableText())
                if searchText != "" {
                    return tonMatch && (coro.nombre.lowercased().contains(searchText.lowercased()) || coro.sName.lowercased().contains(searchText.lowercased()))
                } else {
                    return tonMatch
                }
            }
            break;
        }
        
        tableView.reloadData()
    }
    
    // MARK: table view data source
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return filteredCorosArray!.count
        } else {
            return corosArray!.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CorosTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath) as! CorosTableViewCell
        
        var coro: Coro?
        if searchController.isActive {
            coro = filteredCorosArray![indexPath.row]
        } else {
            coro = corosArray![indexPath.row]
        }
        
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
        if segue.identifier == "showCoroDetail" {
            let tabBarController = segue.destination as? UITabBarController
            let destinationVC = tabBarController?.viewControllers?.first as? CoroDetailViewController
            let secondVC = tabBarController?.viewControllers?.last as? MusicaViewController
            
            if let coroIndex = tableView.indexPathForSelectedRow {
                var coro: Coro
                if searchController.isActive {
                    coro = filteredCorosArray![coroIndex.row]
                } else {
                    coro = corosArray![coroIndex.row]
                }
                destinationVC!.coro = coro
                //para la partitura
                secondVC!.coro = coro
                secondVC!.vc = 1
                navigationItem.title = nil
            }
            
            // hide current tab bar to show other tab bar
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    //MARK: Keyboard
    
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

//MARK: Extensions
extension CorosTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: scope)
    }
}

extension CorosTableViewController: UISearchBarDelegate {
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
