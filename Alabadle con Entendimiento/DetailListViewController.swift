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
    
    var lista:Lista! {
        didSet{
            let defaults = UserDefaults.standard
            let userUID = defaults.string(forKey: "USER_UID")!
            print("listaid: \(lista.id)")
            listaRef = rootRef.child("listas/\(userUID)/\(lista.id)")
            corosEnListaRef = listaRef?.child("corosEnLista")
            lentosRef = corosEnListaRef?.child("lentos")
            rapidosMediosRef = corosEnListaRef?.child("rapidos-medios")
            print(listaRef)
            loadDataWhenReady(completion: {(isReady:Bool) in
                if isReady {
                    self.todosArray = self.lentosArray + self.rapidosMediosArray
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
    var celContract: CorosEnListaContract = CorosEnListaContract()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        corosRef = rootRef.child("coros")
        
        splitViewController!.presentsWithGesture = false
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
                self.todosArray = self.lentosArray + self.rapidosMediosArray
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
            noListView = UIView(frame: CGRect(x: 0, y: 60, width: screenSize.width, height: screenSize.height))
            label = UILabel(frame: CGRect(x: 25, y: 16, width: screenSize.height * 0.75, height: 100))
            
        } else {
            noListView = UIView(frame: CGRect(x: 0, y: 60, width: screenSize.width, height: screenSize.height))
            label = UILabel(frame: CGRect(x: 16, y: 25, width: 325, height: 100))
        }
        
        if lista.id == 10000 {
            noListView!.tag = 100
            noListView!.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1.0)
            label!.textColor = UIColor.black
            label!.font = UIFont(name: label!.font.fontName, size: 25)
            label!.lineBreakMode = NSLineBreakMode.byWordWrapping
            label!.numberOfLines = 3
            label!.text = "No hay ninguna lista creada. Para crear listas, pulsa sobre el boton de +."
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
        rapidosMediosRef?.observeSingleEvent(of: FIRDataEventType.value, with: {(rapSnap) in
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
        
        lentosRef?.observeSingleEvent(of: FIRDataEventType.value, with: {(lentSnap) in
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
                        self.todosArray = self.lentosArray + self.rapidosMediosArray
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
    
    /*
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     //TODO: move coros
     
        /*if editingStyle == UITableViewCellEditingStyle.delete {
            if indexPath.section == 0 {
                let coro = rapidosMediosArray[indexPath.row]
                rapidosMediosArray.remove(at: indexPath.row)
                databaseManager.deleteCoroEnLista(lista._id, coroId: coro._id, flag: true)
            } else {
                let coro = lentosArray[indexPath.row]
                lentosArray.remove(at: indexPath.row)
                databaseManager.deleteCoroEnLista(lista._id, coroId: coro._id, flag: true)
            }
            
            if indexPath.section == 0 {
                rapidosMediosArray = databaseManager.getAllRowsCoroEnLista(lista._id, whereClause: "\(celContract.COLUMN_VELOCIDAD)='RM'")
            } else {
                lentosArray = databaseManager.getAllRowsCoroEnLista(lista._id, whereClause: "\(celContract.COLUMN_VELOCIDAD)='L'")
            }
            
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
            todosArray = lentosArray + rapidosMediosArray
        }*/
    }*/
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.section == 0 {
            reorderCorosEnLista(array: rapidosMediosArray, destination: destinationIndexPath.row,source:  sourceIndexPath.row, section: sourceIndexPath.section)
        } else {
            reorderCorosEnLista(array: lentosArray, destination: destinationIndexPath.row, source: sourceIndexPath.row, section: sourceIndexPath.section)
        }
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
                        coroEnLista = todosArray[coroIndex.row]
                    }
                    destinationVC!.coroEnLista = coroEnLista
                    //para la partitura
                    secondVC!.coro = coroEnLista
                    dump(partiturasArray)
                    secondVC!.partiturasArray = partiturasArray
                    secondVC!.lista = lista
                    navigationItem.title = nil
                }
            }
            
            // hide current tab bar to show other tab bar
            self.tabBarController?.tabBar.isHidden = true
            
          //  self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.primaryHidden
        } else if segue.identifier == "addCorosToList" {
            if let destination = segue.destination as? SelectCorosForListViewController {
                destination.listaRef = listaRef
            }
        }
    }
    
    func reorderCorosEnLista(array: Array<CoroEnLista>, destination: Int, source: Int, section: Int) {
        //TODO: reorder coros
        
       /* if source < destination {
            // borrar todo de tabla en db
            for coro in array {
                databaseManager.deleteCoroEnLista(lista._id, coroId: coro._id, flag: false)
            }
            
            // insertar coros antes del source
            if source != 0 {
                for coro in array {
                    if (coro.orden - 1) < source {
                        databaseManager.agregarCoroALista(lista._id, coroId: coro._id)
                    }
                }
            }
            
            // insertar coros despues del source
            for coro in array {
                if (coro.orden - 1) > source && (coro.orden - 1) <= destination {
                    databaseManager.agregarCoroALista(lista._id, coroId: coro._id)
                }
            }
            
            // insertar el coro que se esta moviendo
            databaseManager.agregarCoroALista(lista._id, coroId: array[source]._id)
            
            // insertar coros despues del destination
            if destination != (array.count - 1) {
                for coro in array {
                    if (coro.orden - 1) > destination {
                        databaseManager.agregarCoroALista(lista._id, coroId: coro._id)
                    }
                }
            }
        } else if source > destination {
            // borrar coros desde destination
            for coro in array {
                if (coro.orden - 1) >= destination {
                    databaseManager.deleteCoroEnLista(lista._id, coroId: coro._id, flag: false)
                }
            }
            
            //insertar el coro que se esta moviendo
            databaseManager.agregarCoroALista(lista._id, coroId: array[source]._id)
            
            //insertar coros desde destination hasta antes de source
            for coro in array {
                if (coro.orden - 1) >= destination  && (coro.orden - 1) < source {
                    databaseManager.agregarCoroALista(lista._id, coroId: coro._id)
                }
            }
            
            //insertar coros despues de source
            if source != (array.count - 1) {
                for coro in array {
                    if (coro.orden - 1) > source {
                        databaseManager.agregarCoroALista(lista._id, coroId: coro._id)
                    }
                }
            }
        }
        
        if section == 0 {
            rapidosMediosArray = databaseManager.getAllRowsCoroEnLista(lista._id, whereClause: "\(celContract.COLUMN_VELOCIDAD)='RM'")
        } else {
            lentosArray = databaseManager.getAllRowsCoroEnLista(lista._id, whereClause: "\(celContract.COLUMN_VELOCIDAD)='L'")
        }
        
        todosArray = lentosArray + rapidosMediosArray
        self.tableView.reloadData()
        */
    }
    
    func listaSelected(newLista: Lista) {
        lista = newLista
    }
}

