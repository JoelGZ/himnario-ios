//
//  SelectCorosForListViewController.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 10/18/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

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
    var scope: String = "Todos"
    var coroIndex: Int?
    
    let rootRef = FIRDatabase.database().reference()
    var corosRef: FIRDatabaseReference!
    var safeCorosRef: FIRDatabaseReference!
    var listaRef: FIRDatabaseReference!
    var corosEnListaRef: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //listaRef is set by parent VC
        corosRef = rootRef.child("coros")
        corosEnListaRef = listaRef.child("corosEnLista")
        
        loadFakeData()
        FIRAuth.auth()!.addStateDidChangeListener { auth, FIRuser in
            if FIRuser != nil {
                let user = User(authData: FIRuser!)
                
                let targetDtAllowedStr = "27-02-2017"           //*********CHANGE THIS DATE************
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy"
                let releaseDate = dateFormatter.date(from: targetDtAllowedStr)
                let today = Date()
                
                if user.email == "test@nomail.com" || today < releaseDate! {
                    self.loadSafeData()
                } else {
                    self.loadData()
                }
            }
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
    
    func loadData() {
        corosRef.queryOrdered(byChild: "orden").observe(FIRDataEventType.value, with: {(snapshot) in
            var tempCoroArray = [Coro]()
            
            for coroSnap in snapshot.children {
                let coro = Coro(snapshot: coroSnap as! FIRDataSnapshot, dbRef: self.corosRef)
                if coro.orden > 0 {
                    tempCoroArray.append(coro)
                }
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
    
    
    @IBAction func doneChoosingCoros(_ sender: AnyObject) {
        var tonalidadArray = Array<String> ()
        var contFinish = 1
        let lentosRef = corosEnListaRef.child("lentos")
        let rapidosMediosRef = corosEnListaRef.child("rapidos-medios")
        lentosRef.observeSingleEvent(of: FIRDataEventType.value, with: {(snapshot) in
            for coroEnListaSnap in snapshot.children {
                let coroEnLista = CoroEnLista(snapshot: coroEnListaSnap as! FIRDataSnapshot)
                if coroEnLista.tonalidad != "$" {
                    if !tonalidadArray.contains(coroEnLista.tonalidad) {
                        tonalidadArray.append(coroEnLista.tonalidad)
                    }
                }
                if contFinish == Int(snapshot.childrenCount) {
                    var tonString = ""
                    for tonalidad in tonalidadArray {
                        tonString += "\(tonalidad), "
                    }
                    let index = tonString.index(tonString.endIndex, offsetBy: -2)
                    tonString = tonString.substring(to: index)
                    let tonalidadUpdate = ["ton_global": tonString]
                    self.listaRef?.updateChildValues(tonalidadUpdate)
                }
                contFinish += 1
            }
        })
        
        contFinish = 1
        rapidosMediosRef.observeSingleEvent(of: FIRDataEventType.value, with: {(snapshot) in
            for coroEnListaSnap in snapshot.children {
                let coroEnLista = CoroEnLista(snapshot: coroEnListaSnap as! FIRDataSnapshot)
                if coroEnLista.tonalidad != "$" {
                    if !tonalidadArray.contains(coroEnLista.tonalidad) {
                        tonalidadArray.append(coroEnLista.tonalidad)
                    }
                }
                if contFinish == Int(snapshot.childrenCount) {
                    var tonString = ""
                    for tonalidad in tonalidadArray {
                        tonString += "\(tonalidad), "
                    }
                    let index = tonString.index(tonString.endIndex, offsetBy: -2)
                    tonString = tonString.substring(to: index)
                    let tonalidadUpdate = ["ton_global": tonString]
                    self.listaRef?.updateChildValues(tonalidadUpdate)
                }
                contFinish += 1
            }
        })
        navigationController?.popToRootViewController(animated: false)
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
        
        corosEnListaRef.observeSingleEvent(of: FIRDataEventType.value, with: {(snapshot) in
            if coro.velletra == "L" || self.isMedioEspecial(medioId: coro.id) {
                let lentosRef = self.corosEnListaRef.child("lentos")
                if snapshot.hasChild("lentos") {    //si hay coros lentos
                    lentosRef.observeSingleEvent(of: FIRDataEventType.value, with: {(lentSnap) in
                        let coroRef = lentosRef.child("\(coro.id)")
                        if lentSnap.hasChild("\(coro.id)") { //si el coro existe -> eliminar, si no, agregar
                            coroRef.removeValue()
                            tableView.reloadData()
                        } else {
                            coroRef.setValue(self.setupCoroForList(coro: coro, corosInVelCount: Int(lentSnap.childrenCount)))
                            tableView.reloadData()
                        }
                    })
                } else {        //agregar primer coro a lentos
                    let coroRef = lentosRef.child("\(coro.id)")
                    coroRef.setValue(self.setupCoroForList(coro: coro, corosInVelCount: 0))
                    tableView.reloadData()
                }
            } else {
                //rapidos y medios
                let rapidosMediosRef = self.corosEnListaRef.child("rapidos-medios")
                if snapshot.hasChild("rapidos-medios") {
                    rapidosMediosRef.observeSingleEvent(of: FIRDataEventType.value, with: {(rapSnap) in
                        let coroRef = rapidosMediosRef.child("\(coro.id)")
                        if rapSnap.hasChild("\(coro.id)") {
                            coroRef.removeValue()
                            tableView.reloadData()
                        } else {
                            coroRef.setValue(self.setupCoroForList(coro: coro, corosInVelCount: Int(rapSnap.childrenCount)))
                            tableView.reloadData()
                        }
                    })
                } else {            //agregar primer coro a rapidos-medios
                    let coroRef = rapidosMediosRef.child("\(coro.id)")
                    coroRef.setValue(self.setupCoroForList(coro: coro, corosInVelCount: 0))
                    tableView.reloadData()
                }
            }
        })
    }
    
    func setupCoroForList(coro: Coro, corosInVelCount: Int) -> Any {
        var tonalidad = coro.tonalidad
        if coro.ton_alt != "" {
            tonalidad = "$"
        }
        return [
            "nombre": coro.nombre,
            "orden": corosInVelCount,
            "ton": tonalidad
        ]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCoroDetail" {
            let destination = segue.destination as! CoroDetailViewController
            var coro: Coro
            if searchController.isActive {
                coro = filteredCorosArray![coroIndex!]
            } else {
                coro = corosArray![coroIndex!]
            }
            destination.coro = coro
        }
    }
    
    // Verificar si el coro medio se pone con los lentos o no
    func isMedioEspecial(medioId: Int) -> Bool {
        let mediosEspeciales = [1001,82,261,1019,1012,84,174,1006,1008,5,338]
        
        for coroId in mediosEspeciales {
            if coroId == medioId {
                return true
            }
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SelectCorosForListTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SelectCorosForListTableViewCell
        
        var coro: Coro
        if searchController.isActive {
            coro = filteredCorosArray![indexPath.row]
        } else {
            coro = corosArray![indexPath.row]
        }
        
        // Checkmark or Disclosure -> is it already in the list?
        var velRef: FIRDatabaseReference
        if coro.velletra == "L" || isMedioEspecial(medioId: coro.id) {
            velRef = corosEnListaRef.child("lentos")
        } else {
            velRef = corosEnListaRef.child("rapidos-medios")
        }
        
        velRef.observeSingleEvent(of: FIRDataEventType.value, with: {(snapshot) in
            if snapshot.hasChild("\(coro.id)") {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            }
        })
        
        //Fill table with data
        cell.nombreCoroLabel.text = coro.nombre
        if searchController.isActive && scope != "Todos" {
            if coro.ton_alt != "" {
                cell.tonalidadLabel.text = "\(coro.tonalidad),\(coro.ton_alt)"
            } else {
                cell.tonalidadLabel.text = coro.tonalidad
            }
        } else {
            cell.tonalidadLabel.text = coro.tonalidad
        }
        cell.velocidadLabel.text = coro.velletra.getReadableText()
        
        return cell

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
