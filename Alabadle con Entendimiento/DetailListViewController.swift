//
//  DetailListViewController.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 10/11/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import UIKit
import FirebaseDatabase

class DetailListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, ListaSelectionDelegate {
    
    @IBOutlet weak var tituloLabel: UILabel!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tonalidadLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var toolBar: UIToolbar!
    
    var deleteListButton: UIBarButtonItem!
    var actionInListButton: UIBarButtonItem!
    var addCorosButton: UIBarButtonItem!
    var editListButton: UIBarButtonItem!
    var resultNumber: Int?
    
    var noListView: UIView?
    var label: UILabel?
    var createListButton: UIButton?
    
    var lista:Lista! {
        didSet{
            let defaults = UserDefaults.standard
            let userUID = defaults.string(forKey: "USER_UID")!
            listaRef = rootRef.child("listas/\(userUID)/\(lista.id)")
            corosEnListaRef = listaRef?.child("corosEnLista")
            lentosRef = corosEnListaRef?.child("lentos")
            rapidosMediosRef = corosEnListaRef?.child("rapidos-medios")
            loadDataWhenReady(completion: {(isReady:Bool) in
                if isReady {
                    self.todosArray = self.rapidosMediosArray + self.lentosArray
                    self.partiturasArray = self.partiturasRapidosArray + self.partiturasLentosArray
                    if self.tableView != nil {
                        self.tableView.reloadData()
                        self.setupLabels()
                    }
                }
            })
        }
    }
    
    let rootRef = FIRDatabase.database().reference()
    var listaRef: FIRDatabaseReference?
    var corosRef: FIRDatabaseReference?
    var corosEnListaRef: FIRDatabaseReference?
    var lentosRef: FIRDatabaseReference?
    var rapidosMediosRef: FIRDatabaseReference?
    
    var lentosArray = Array<CoroEnLista>()
    var rapidosMediosArray = Array<CoroEnLista>()
    var todosArray = Array<CoroEnLista>()
    var partiturasRapidosArray = Array<String>()
    var partiturasLentosArray = Array<String>()
    var partiturasArray = Array<String>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        corosRef = rootRef.child("coros")
        
        //splitViewController!.presentsWithGesture = false check to see what this is
        activityIndicator.isHidden = true
        
        deleteListButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.deleteListAction(sender:)))
        actionInListButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.shareListAction(sender:)))
        if UIDevice.current.userInterfaceIdiom == .phone {
            addCorosButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(DetailListViewController.addCorosToList))
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            addCorosButton = UIBarButtonItem(title: "Agregar Coros", style: .plain, target: self, action: #selector(DetailListViewController.addCorosToList))
        }
        editListButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(DetailListViewController.startEditingList))
        
        //Stop screen from dimming
        UIApplication.shared.isIdleTimerDisabled = true
        
        if lista == nil {
            lista = Lista(id: 10000, nombreLista: "", ton_global: "", ton_rap: "", ton_lent: "")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let screenSize: CGRect = UIScreen.main.bounds
        let maxSize = max(screenSize.width,screenSize.height)
        if maxSize >= 736 {         //If it is iPhone 6s Plus or iPad
            self.navigationItem.rightBarButtonItems = [editButtonItem, addCorosButton, actionInListButton, deleteListButton]
            self.tabBarController?.tabBar.isHidden = false
        } else {
            self.tabBarController?.tabBar.isHidden = true
            var items = [UIBarButtonItem]()
            items.append(deleteListButton)
            items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
            items.append(actionInListButton)
            toolBar.items = items
            self.navigationItem.rightBarButtonItems = [editButtonItem, addCorosButton]
        }
        
        loadDataWhenReady(completion: {(isReady:Bool) in
            if isReady {
                self.todosArray = self.rapidosMediosArray + self.lentosArray
                self.partiturasArray = self.partiturasRapidosArray + self.partiturasLentosArray
                self.tableView.reloadData()
            }
        })
        setupNoListView()
        tableView.reloadData()
        self.navigationController?.isNavigationBarHidden = false
        self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    
    
    func setupNoListView() {
        let screenSize: CGRect = UIScreen.main.bounds
        
        if UIDevice.current.orientation.isLandscape {
            label = UILabel(frame: CGRect(x: 25, y: (screenSize.height/2 - 50), width: 270, height: 30))
            noListView = UIView(frame: CGRect(x: 0, y: 30, width: screenSize.width, height: screenSize.height))
        } else {
            label = UILabel(frame: CGRect(x: 16, y: (screenSize.width/2 - 15), width: 270, height: 30))
            noListView = UIView(frame: CGRect(x: 0, y: 60, width: screenSize.width, height: screenSize.height))
        }
        label?.center.x = self.view.center.x
        
        if lista.id == 10000 {
            noListView!.tag = 100
            noListView!.backgroundColor = UIColor.white
            label!.textColor = UIColor.lightGray
            label!.font = UIFont(name: label!.font.fontName, size: 20)
            label!.lineBreakMode = NSLineBreakMode.byWordWrapping
            label!.numberOfLines = 3
            
            let screenSize: CGRect = UIScreen.main.bounds
            let maxSize = max(screenSize.width,screenSize.height)
            if maxSize >= 736 {         //If it is iPhone 6s Plus or iPad
                label!.text = "No hay ninguna lista creada. Para crear listas, pulsa sobre el boton de +."
            } else {
                label!.text = "No hay ninguna lista creada."
                if UIDevice.current.orientation.isLandscape {
                    createListButton = UIButton(frame: CGRect(x: 35, y: (screenSize.height/2-15), width: 100, height: 30))
                } else {
                    createListButton = UIButton(frame: CGRect(x: 16, y: (screenSize.width/2+20), width: 100, height: 30))
                }
                createListButton?.addTarget(self, action: #selector(segueToNewList), for: .touchUpInside)
                createListButton?.setTitle("Crear Lista", for: .normal)
                createListButton?.setTitleColor(self.view.tintColor, for: .normal)
                createListButton?.center.x = self.view.center.x
                noListView!.addSubview(createListButton!)
            }
            
            noListView!.addSubview(label!)
            
            self.view.addSubview(noListView!)
            
            deleteListButton.isEnabled = false
            actionInListButton.isEnabled = false
            addCorosButton.isEnabled = false
            editButtonItem.isEnabled = false
        } else {
            for view in self.view.subviews {
                if view.tag == 100 {
                    view.removeFromSuperview()
                }
            }
            setupLabels()
            deleteListButton.isEnabled = true
            actionInListButton.isEnabled = true
            addCorosButton.isEnabled = true
            editButtonItem.isEnabled = true
        }
    }
    
    override func viewWillLayoutSubviews() {
        if lista.id != 10000 {
            if noListView!.tag == 100 {
                noListView!.removeFromSuperview()
            }
            
        }
        setupNoListView()
    }
    
    func segueToNewList() {
        self.performSegue(withIdentifier: "listaDesdeDetail", sender: nil)
    }
    
    //Load Data
    func setupLabels(){
        tituloLabel.text = lista.nombreLista
        //TODO: settle tonalidad
        tonalidadLabel.text = lista.ton_global
    }
    
    func loadDataWhenReady(completion:@escaping (_ isReady: Bool) -> Void ) {
        //if both arrays have been set (readyNumber == 2)then indicate it is ready to continue
        var readyNumber = 0
        var rapidosCounter = 0
        var lentosCounter = 0
        
        partiturasRapidosArray = []
        partiturasLentosArray = []
        
        rapidosMediosRef?.queryOrdered(byChild: "orden").observeSingleEvent(of: FIRDataEventType.value, with: {(rapSnap) in
            var tempArray1 = [CoroEnLista]()
            var partRapArray = Array<String>()
            for coroRMChild in rapSnap.children {
                let coroRMEnLista = CoroEnLista(snapshot: (coroRMChild as! FIRDataSnapshot))
                tempArray1.append(coroRMEnLista)
                coroRMEnLista.convertToCoro(completion: {(coroReturned: Coro) in
                    partRapArray.append(coroReturned.partitura)
                    self.partiturasRapidosArray = partRapArray
                    rapidosCounter += 1
                    if readyNumber == 2 && rapidosCounter == Int(rapSnap.childrenCount) {
                        completion(true)
                    }
                })
            }
            self.rapidosMediosArray = tempArray1
            readyNumber += 1
        })
        
        lentosRef?.queryOrdered(byChild: "orden").observeSingleEvent(of: FIRDataEventType.value, with: {(lentSnap) in
            var tempArray2 = [CoroEnLista]()
            var partLentArray = Array<String>()
            for coroLentoChild in lentSnap.children {
                let coroLentoEnLista = CoroEnLista(snapshot: (coroLentoChild as! FIRDataSnapshot))
                tempArray2.append(coroLentoEnLista)
                coroLentoEnLista.convertToCoro(completion: {(coroReturned: Coro) in
                    partLentArray.append(coroReturned.partitura)
                    self.partiturasLentosArray = partLentArray
                    lentosCounter += 1
                    if readyNumber == 2 && lentosCounter == Int(lentSnap.childrenCount) {
                        completion(true)
                    }
                })
            }
            self.lentosArray = tempArray2
            readyNumber += 1
        })
    }
    
    //MARK: Actions
    func addCorosToList() {
        self.performSegue(withIdentifier: "addCorosToList", sender: nil)
    }
    
    func startEditingList() {
        self.tableView.isEditing = !self.isEditing
    }
    
    @IBAction func deleteListAction(sender: AnyObject) {
        let alert = UIAlertController(title: "¿Está seguro?", message: "La lista se eliminará definitivamente.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction!) -> Void in self.deleteList()})
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = self.view.bounds
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func shareListAction(sender: AnyObject) {
        
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        
        DispatchQueue.main.async {
            self.shareList(sender: sender)
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
    }
    
    @IBAction func settleTonalidadAction(sender: UIButton) {
    
        let alert = UIAlertController(title: "Establezca la tonalidad", message: "Establezca la tonalidad en la que desea cantar este coro.", preferredStyle: .alert)
        let singleCoroRef = corosRef?.child("\(sender.tag)")
 
        singleCoroRef?.observeSingleEvent(of: FIRDataEventType.value, with: {(snapshot) in
            let coro = Coro(snapshot: snapshot, coroId: sender.tag)
            
            let tonPrincipalAction = UIAlertAction(title: coro.tonalidad.getReadableText(), style: .default, handler: {(alert: UIAlertAction!) -> Void in self.updateTonalidadDeCoro(coro: coro, tonalidad: coro.tonalidad)})
            let tonAlternativaAction = UIAlertAction(title: coro.ton_alt.getReadableText(), style: .default, handler: {(alert: UIAlertAction!) -> Void in self.updateTonalidadDeCoro(coro: coro, tonalidad: coro.ton_alt)
                sender.isHidden = true})
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(tonPrincipalAction)
            alert.addAction(tonAlternativaAction)
            alert.addAction(cancelAction)
            
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController?.sourceRect = self.view.bounds
            
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    //MARK: Deleting, sharing and updating functions
    func deleteList() { 
        listaRef?.removeValue()
        self.navigationController?.navigationController!.popToRootViewController(animated: true)
    }
    
    func updateTonalidadDeCoro(coro: Coro, tonalidad: String) {
        //TODO: update tonalidad de coro
        
      /*  let flag = databaseManager.updateTonalidadDeCoroEnLista(lista._id, coroId: coro._id, tonalidad: tonalidad)
        
        DispatchQueue.main.async(execute: {
            if flag {
                self.loadDataWhenReady(completion: {(isReady:Bool) in
                    if isReady {
                        self.todosArray = self.rapidosMediosArray + self.lentosArray
                        self.partiturasArray = self.partiturasRapidosArray + self.partiturasLentosArray
                        self.tableView.reloadData()
                    }
                })
                self.tableView.reloadData()
                self.setupLabels()
            }
        });*/
    }
    
    func shareList(sender: AnyObject){
        var sharingItems = [AnyObject]()
        let sharingText = self.lista.toString(listaURL: listaRef!)
        sharingItems.append(sharingText as AnyObject)
        
        let shareVC = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        shareVC.excludedActivityTypes = [UIActivityType.airDrop,UIActivityType.addToReadingList,UIActivityType.assignToContact,UIActivityType.postToTencentWeibo,UIActivityType.postToVimeo,UIActivityType.saveToCameraRoll,UIActivityType.postToWeibo]
        if let popoverController = shareVC.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        
        self.present(shareVC, animated: true, completion: nil)
    }
    
    
    //MARK: TableView properties
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return rapidosMediosArray.count
        } else {
            return lentosArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = ""
        if section == 0 {
            title = "RAPIDOS Y MEDIOS"
            if ((lista.ton_rap != lista.ton_lent) && !(((lentosArray.count == 0) && (rapidosMediosArray.count >= 1)) || ((rapidosMediosArray.count == 0) && (lentosArray.count >= 1)))) {
                title += " - \(lista.ton_rap)"
            }
        } else {
            title = "LENTOS"
            if ((lista.ton_rap != lista.ton_lent) && !(((lentosArray.count == 0) && (rapidosMediosArray.count >= 1)) || ((rapidosMediosArray.count == 0) && (lentosArray.count >= 1)))) {
                title += " - \(lista.ton_lent)"
            }
        }
        return title
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        var title = ""
        if section == 0 {
            title = "RAPIDOS Y MEDIOS"
            if ((lista.ton_rap != lista.ton_lent) && !(((lentosArray.count == 0) && (rapidosMediosArray.count >= 1)) || ((rapidosMediosArray.count == 0) && (lentosArray.count >= 1)))) {
                title += " - \(lista.ton_rap)"
            }
        } else {
            title = "LENTOS"
            if ((lista.ton_rap != lista.ton_lent) && !(((lentosArray.count == 0) && (rapidosMediosArray.count >= 1)) || ((rapidosMediosArray.count == 0) && (lentosArray.count >= 1)))) {
                title += " - \(lista.ton_lent)"
            }
        }
        
        headerView.textLabel!.text = title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CoroInListaCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CoroEnListaTableViewCell
        
        
        let section = indexPath.section
        
        if section == 0 {
            let coroEnLista = rapidosMediosArray[indexPath.row]
            coroEnLista.convertToCoro(){ (coroResultante:Coro) in
                let coro = coroResultante
                self.cellSetup(cell: cell, coro: coro, coroEnLista: coroEnLista, section: section)
            }
        } else {
            let coroEnLista = lentosArray[indexPath.row]
            coroEnLista.convertToCoro(){(coroResultante: Coro) in
                let coro = coroResultante
                self.cellSetup(cell: cell, coro: coro, coroEnLista: coroEnLista, section: section)
            }
        }
    
        return cell
    }
    
    func cellSetup(cell: CoroEnListaTableViewCell, coro: Coro, coroEnLista: CoroEnLista, section: Int) {
        cell.tituloCoroLabel.text = coro.nombre
        
        if coroEnLista.tonalidad == "" {
            cell.settleTonalidadButton.setTitle("\(coro.tonalidad)/\(coro.ton_alt)", for: .normal)
            cell.settleTonalidadButton.tag = coroEnLista.id
            cell.settleTonalidadButton.setTitleColor(self.view.tintColor, for: .normal)
            cell.settleTonalidadButton.isHidden = false
            cell.settleTonalidadButton.isEnabled = true
        } else {
            
            let tonRapidosArray = lista.ton_rap.components(separatedBy: ",")
            let tonLentosArray = lista.ton_lent.components(separatedBy: ",")
            if section == 0 {
                if tonRapidosArray.count > 1 {
                    cell.settleTonalidadButton.setTitleColor(UIColor.lightGray, for: .normal)
                    cell.settleTonalidadButton.setTitle(coroEnLista.tonalidad, for: .normal)
                    cell.settleTonalidadButton.isHidden = false
                    cell.settleTonalidadButton.isEnabled = false
                } else {
                    cell.settleTonalidadButton.isHidden = true
                }
            } else if section == 1 {
                if tonLentosArray.count > 1 {
                    cell.settleTonalidadButton.setTitleColor(UIColor.lightGray, for: .normal)
                    cell.settleTonalidadButton.setTitle(coroEnLista.tonalidad, for: .normal)
                    cell.settleTonalidadButton.isHidden = false
                    cell.settleTonalidadButton.isEnabled = false
                } else {
                    cell.settleTonalidadButton.isHidden = true
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    //delete coros
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            if indexPath.section == 0 {
                
                rapidosMediosRef?.observeSingleEvent(of: FIRDataEventType.value, with: {(snapshot) in
                    for coroEnListaSnap in snapshot.children {
                        let coro = CoroEnLista(snapshot: coroEnListaSnap as! FIRDataSnapshot)
                        let coroRef = self.rapidosMediosRef?.child("\((coroEnListaSnap as! FIRDataSnapshot).key)")
                        if coro.orden == indexPath.row {
                            coroRef?.removeValue()
                        } else if coro.orden > indexPath.row {
                            let update = ["orden": (coro.orden - 1)]
                            coroRef?.updateChildValues(update)
                        }
                    }
                })
            } else {
                lentosRef?.observeSingleEvent(of: FIRDataEventType.value, with: {(snapshot) in
                    for coroEnListaSnap in snapshot.children {
                        let coro = CoroEnLista(snapshot: coroEnListaSnap as! FIRDataSnapshot)
                        let coroRef = self.lentosRef?.child("\((coroEnListaSnap as! FIRDataSnapshot).key)")
                        if coro.orden == indexPath.row {
                            coroRef?.removeValue()
                        } else if coro.orden > indexPath.row {
                            let update = ["orden": (coro.orden - 1)]
                            coroRef?.updateChildValues(update)
                        }
                    }
                })
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        reorderCorosEnLista(destination: destinationIndexPath.row, source:  sourceIndexPath.row, section: sourceIndexPath.section)
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            var row = 0
            if sourceIndexPath.section < proposedDestinationIndexPath.section {
                row = self.tableView(tableView, numberOfRowsInSection: sourceIndexPath.section) - 1
            }
            return IndexPath(row: row, section: sourceIndexPath.section)
        }
        return proposedDestinationIndexPath
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        self.tableView.isEditing = editing
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCoroDetailPager" {
            let tabBarController = segue.destination as? UITabBarController
            let destinationVC = tabBarController?.viewControllers?.first as? CoroDetailWPagerViewController
            let secondVC = tabBarController?.viewControllers?.last as? MusicaPagerParentViewController
            
            if tableView.indexPathForSelectedRow != nil {
                if let coroIndex = tableView.indexPathForSelectedRow {
                    var coro = Coro(id: 1, orden: 1, nombre: "", cuerpo: "", tonalidad: "", ton_alt: "", velletra: "", tiempo: 60, audio: "", partitura: "", autormusica: "", autorletra: "", cita: "", historia: "", sName: "")
                    let coroEnLista: CoroEnLista!
                    if coroIndex.section == 0 {
                        coroEnLista = rapidosMediosArray[coroIndex.row]
                    } else {
                        coroEnLista = todosArray[coroIndex.row + rapidosMediosArray.count]
                    }
                    destinationVC!.coroEnLista = coroEnLista
                    //para la partitura
                    secondVC!.coro = coroEnLista
                    dump(partiturasArray)
                    secondVC!.partiturasArray = partiturasArray
                    var corosArray = Array<Coro>()
                    for coroEnLista in todosArray {
                        coroEnLista.convertToCoro(completion: {(coro) in
                            corosArray.append(coro)
                            if corosArray.count == self.todosArray.count {
                                secondVC!.corosArray = corosArray
                            }
                        })
                    }
                    secondVC!.corosEnListaRef = corosEnListaRef
                    secondVC!.lista = lista
                    if coroIndex.section == 0 {
                        secondVC!.index = coroIndex.row
                    } else {
                        secondVC!.index = coroIndex.row + self.rapidosMediosArray.count
                    }
                    navigationItem.title = nil
                    
                    let screenSize: CGRect = UIScreen.main.bounds
                    let maxSize = max(screenSize.width,screenSize.height)
                    if maxSize >= 736 {
                        self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.primaryHidden
                    }
                }
            }
            
            // hide current tab bar to show other tab bar
            self.tabBarController?.tabBar.isHidden = true
        } else if segue.identifier == "addCorosToList" {
            if let destination = segue.destination as? SelectCorosForListViewController {
                destination.listaRef = listaRef
            }
        }
    }
    
    func reorderCorosEnLista(destination: Int, source: Int, section: Int) {
        if source < destination {
            var contDespuesDeSource = 0
            if section == 0 {
                rapidosMediosRef?.observeSingleEvent(of: FIRDataEventType.value, with: {(snapshot) in
                    for coroSnap in snapshot.children {
                        let coro = CoroEnLista(snapshot: coroSnap as! FIRDataSnapshot)
                        let coroInListaRef = self.rapidosMediosRef?.child("\(coro.id)")
                        if coro.orden > source && coro.orden <= destination {
                            let updates = ["orden": source + contDespuesDeSource]
                            coroInListaRef?.updateChildValues(updates)
                            contDespuesDeSource += 1
                        } else if coro.orden == source {
                            let updates = ["orden": destination]
                            coroInListaRef?.updateChildValues(updates)
                        }
                    }
                })
            } else {
                lentosRef?.observeSingleEvent(of: FIRDataEventType.value, with: {(snapshot) in
                    for coroSnap in snapshot.children {
                        let coro = CoroEnLista(snapshot: coroSnap as! FIRDataSnapshot)
                        let coroInListaRef = self.rapidosMediosRef?.child("\(coro.id)")
                        if coro.orden > source && coro.orden <= destination {
                            let updates = ["orden": source + contDespuesDeSource]
                            coroInListaRef?.updateChildValues(updates)
                            contDespuesDeSource += 1
                        } else if coro.orden == source {
                            let updates = ["orden": destination]
                            coroInListaRef?.updateChildValues(updates)
                        }
                    }
                })
            }
        } else if source > destination {
            var contDesdeDestinationyAntesDeSource = 1
            if section == 0 {
                rapidosMediosRef?.observeSingleEvent(of: FIRDataEventType.value, with: {(snapshot) in
                    for coroSnap in snapshot.children {
                        let coro = CoroEnLista(snapshot: coroSnap as! FIRDataSnapshot)
                        let coroInListaRef = self.rapidosMediosRef?.child("\(coro.id)")
                        
                        if coro.orden == source {
                            let updates = ["orden": destination]
                            coroInListaRef?.updateChildValues(updates)
                        } else if coro.orden >= destination && coro.orden < source {
                            let updates = ["orden": destination + contDesdeDestinationyAntesDeSource]
                            coroInListaRef?.updateChildValues(updates)
                            contDesdeDestinationyAntesDeSource += 1
                        }
                    }
                })
            }
        }
    }
    
    func listaSelected(newLista: Lista) {
        lista = newLista
    }
}

