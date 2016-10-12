//
//  DetailListViewController.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 10/11/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import UIKit

class DetailListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate {
    
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
            loadCorosEnListaData()
            setupNoListView()
            tableView.reloadData()
        }
    }
    
    var databaseManager: DatabaseManager = DatabaseManager()
    
    var lentosArray = Array<CoroEnLista>()
    var rapidosMediosArray = Array<CoroEnLista>()
    var todosArray = Array<CoroEnLista>()
    var celContract: CorosEnListaContract = CorosEnListaContract()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        splitViewController!.presentsWithGesture = false
        activityIndicator.hidden = true
        
        deleteListButton = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: #selector(DetailListViewController.deleteListAction(_:)))
        actionInListButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(DetailListViewController.shareListAction(_:)))
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            addCorosButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(DetailListViewController.addCorosToList))
        } else if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            addCorosButton = UIBarButtonItem(title: "Agregar Coros", style: .Plain, target: self, action: #selector(DetailListViewController.addCorosToList))
        }
        editListButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(DetailListViewController.startEditingList))
        
        //Stop screen from dimming
        UIApplication.sharedApplication().idleTimerDisabled = true
    }
    
    override func viewWillAppear(animated: Bool) {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let maxSize = max(screenSize.width,screenSize.height)
        if maxSize >= 736 {         //If it is iPhone 6s Plus or iPad
            self.navigationItem.rightBarButtonItems = [editButtonItem(), addCorosButton, actionInListButton]
            self.tabBarController?.tabBar.hidden = false
        } else {
            tabBarController?.tabBar.hidden = true
            var items = [UIBarButtonItem]()
            items.append(deleteListButton)
            items.append(UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil))
            items.append(actionInListButton)
            toolBar.items = items
            self.navigationItem.rightBarButtonItems = [editButtonItem(), addCorosButton]
        }
        
        loadCorosEnListaData()
        setupNoListView()
        tableView.reloadData()
        self.navigationController?.navigationBarHidden = false
        self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
    }
    
    override func viewWillDisappear(animated: Bool) {
        UIApplication.sharedApplication().idleTimerDisabled = false
    }
    
    func setupNoListView() {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            noListView = UIView(frame: CGRect(x: 0, y: 60, width: screenSize.width, height: screenSize.height))
            label = UILabel(frame: CGRect(x: 25, y: 16, width: screenSize.height * 0.75, height: 100))
            
        } else {
            noListView = UIView(frame: CGRect(x: 0, y: 60, width: screenSize.width, height: screenSize.height))
            label = UILabel(frame: CGRect(x: 16, y: 25, width: 325, height: 100))
        }
        
        if lista._id == 10000 {
            noListView!.tag = 100
            noListView!.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1.0)
            label!.textColor = UIColor.blackColor()
            label!.font = UIFont(name: label!.font.fontName, size: 25)
            label!.lineBreakMode = NSLineBreakMode.ByWordWrapping
            label!.numberOfLines = 3
            label!.text = "No hay ninguna lista creada. Para crear listas, pulsa sobre el boton de +."
            noListView!.addSubview(label!)
            
            
            self.view.addSubview(noListView!)
            
            deleteListButton.enabled = false
            actionInListButton.enabled = false
            addCorosButton.enabled = false
            editButtonItem().enabled = false
        } else {
            for view in self.view.subviews {
                if view.tag == 100 {
                    view.removeFromSuperview()
                }
            }
            setupLabels()
            deleteListButton.enabled = true
            actionInListButton.enabled = true
            addCorosButton.enabled = true
            editButtonItem().enabled = true
        }
    }
    
    override func viewWillLayoutSubviews() {
        if lista._id != 10000 {
            if noListView!.tag == 100 {
                noListView!.removeFromSuperview()
            }
            
        }
        setupNoListView()
    }
    
    //Load Data
    func setupLabels(){
        tituloLabel.text = lista.nombreLista
        if lista.ton_global.isEmpty {
            tonalidadLabel.text = "Tonalidad no se ha resuelto"
        }
        
        tonalidadLabel.text = lista.ton_global
    }
    
    func loadCorosEnListaData() -> Int {
        let whereLentos = "\(celContract.COLUMN_VELOCIDAD)='L'"
        let whereRapidosMedios = "\(celContract.COLUMN_VELOCIDAD)='RM'"
        lentosArray = databaseManager.getAllRowsCoroEnLista(lista._id, whereClause: whereLentos)
        rapidosMediosArray = databaseManager.getAllRowsCoroEnLista(lista._id, whereClause: whereRapidosMedios)
        todosArray = lentosArray + rapidosMediosArray
        return todosArray.count
    }
    
    //MARK: Actions
    func addCorosToList() {
        self.performSegueWithIdentifier("addCorosToList", sender: nil)
    }
    
    func newList() {
        splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
    }
    
    func startEditingList() {
        self.tableView.editing = !self.editing
    }
    
    @IBAction func deleteListAction(sender: AnyObject) {
        let alert = UIAlertController(title: "¿Está seguro?", message: "La lista se eliminará definitivamente.", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: {(alert: UIAlertAction!) -> Void in self.deleteList()})
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = self.view.bounds
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func shareListAction(sender: AnyObject) {
        
        self.activityIndicator.startAnimating()
        self.activityIndicator.hidden = false
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(1 * NSEC_PER_SEC)), dispatch_get_main_queue()){
            self.shareList(sender)
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
        };
    }
    
    @IBAction func settleTonalidadAction(sender: UIButton) {
        
        let alert = UIAlertController(title: "Establezca la tonalidad", message: "Establezca la tonalidad en la que desea cantar este coro.", preferredStyle: .Alert)
        let coro = databaseManager.getCoroByID(sender.tag)
        let tonPrincipalAction = UIAlertAction(title: coro.tonalidad.getReadableText(), style: .Default, handler: {(alert: UIAlertAction!) -> Void in self.updateTonalidadDeCoro(coro, tonalidad: coro.tonalidad)})
        let tonAlternativaAction = UIAlertAction(title: coro.ton_alt.getReadableText(), style: .Default, handler: {(alert: UIAlertAction!) -> Void in self.updateTonalidadDeCoro(coro, tonalidad: coro.ton_alt)
            sender.hidden = true})
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alert.addAction(tonPrincipalAction)
        alert.addAction(tonAlternativaAction)
        alert.addAction(cancelAction)
        
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = self.view.bounds
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: Deleting, sharing and updating functions
    func deleteList() {
        //Deleting files related to list
        let documentsURL = NSURL(
            fileURLWithPath: NSSearchPathForDirectoriesInDomains(
                .DocumentDirectory, .UserDomainMask, true).first!,
            isDirectory: true
        )
        let txtFile = documentsURL.URLByAppendingPathComponent("\(lista.archivo).txt")
        let aelFile = documentsURL.URLByAppendingPathComponent("\(lista.archivo).ael")
        
        let fileManager = NSFileManager.defaultManager()
        //I think this if will not be necesarry for txt
        if (fileManager.fileExistsAtPath(txtFile.path!)) {
            do {
                try fileManager.removeItemAtPath(txtFile.path!)
            } catch {
                print("ERROR: \(error)")
            }
            
            print("FILE AVAILABLE")
        } else {
            print("FILE NOT AVAILABLE")
        }
        if (fileManager.fileExistsAtPath(aelFile.path!)) {
            do {
                try fileManager.removeItemAtPath(aelFile.path!)
            } catch {
                print("ERROR: \(error)")
            }
            print("FILE AEL AVAILABLE")
        } else {
            print("FILE NOT AVAILABLE")
        }
        
        databaseManager.deleteLista(lista._id)
        self.navigationController?.navigationController!.popToRootViewControllerAnimated(true)
    }
    
    func updateTonalidadDeCoro(coro: Coro, tonalidad: String) {
        let flag = databaseManager.updateTonalidadDeCoroEnLista(lista._id, coroId: coro._id, tonalidad: tonalidad)
        
        dispatch_async(dispatch_get_main_queue(), {
            if flag {
                self.loadCorosEnListaData()
                self.tableView.reloadData()
                self.setupLabels()
            }
        });
    }
    
    func shareList(sender: AnyObject){
        
        var sharingItems = [AnyObject]()
        let sharingText = self.lista.toString()
        sharingItems.append(sharingText)
        
        let shareVC = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        shareVC.excludedActivityTypes = [UIActivityTypeAirDrop,UIActivityTypeAddToReadingList,UIActivityTypeAssignToContact,UIActivityTypePostToTencentWeibo,UIActivityTypePostToVimeo,UIActivityTypeSaveToCameraRoll,UIActivityTypePostToWeibo]
        if let popoverController = shareVC.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        
        self.presentViewController(shareVC, animated: true, completion: nil)
    }
    
    
    //MARK: TableView properties
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return rapidosMediosArray.count
        } else {
            return lentosArray.count
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = ""
        let lentosArray = databaseManager.getAllRowsCoroEnLista(lista._id, whereClause: "\(celContract.COLUMN_VELOCIDAD)='L'")
        let rapidosArray = databaseManager.getAllRowsCoroEnLista(lista._id, whereClause: "\(celContract.COLUMN_VELOCIDAD)='RM'")
        if section == 0 {
            title = "RAPIDOS Y MEDIOS"
            if ((lista.ton_rap != lista.ton_lent) && !(((lentosArray.count == 0) && (rapidosArray.count >= 1)) || ((rapidosArray.count == 0) && (lentosArray.count >= 1)))) {
                title += " - \(lista.ton_rap)"
            }
        } else {
            title = "LENTOS"
            if ((lista.ton_rap != lista.ton_lent) && !(((lentosArray.count == 0) && (rapidosArray.count >= 1)) || ((rapidosArray.count == 0) && (lentosArray.count >= 1)))) {
                title += " - \(lista.ton_lent)"
            }
        }
        return title
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        var title = ""
        let lentosArray = databaseManager.getAllRowsCoroEnLista(lista._id, whereClause: "\(celContract.COLUMN_VELOCIDAD)='L'")
        let rapidosArray = databaseManager.getAllRowsCoroEnLista(lista._id, whereClause: "\(celContract.COLUMN_VELOCIDAD)='RM'")
        if section == 0 {
            title = "RAPIDOS Y MEDIOS"
            if ((lista.ton_rap != lista.ton_lent) && !(((lentosArray.count == 0) && (rapidosArray.count >= 1)) || ((rapidosArray.count == 0) && (lentosArray.count >= 1)))) {
                title += " - \(lista.ton_rap)"
            }
        } else {
            title = "LENTOS"
            if ((lista.ton_rap != lista.ton_lent) && !(((lentosArray.count == 0) && (rapidosArray.count >= 1)) || ((rapidosArray.count == 0) && (lentosArray.count >= 1)))) {
                title += " - \(lista.ton_lent)"
            }
        }
        
        headerView.textLabel!.text = title
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "CoroInListaCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! CoroEnListaTableViewCell
        
        
        let section = indexPath.section
        let coro:Coro?
        let coroEnLista: CoroEnLista?
        
        if section == 0 {
            coroEnLista = rapidosMediosArray[indexPath.row]
            coro = coroEnLista!.convertToCoro()
        } else {
            coroEnLista = lentosArray[indexPath.row]
            coro = coroEnLista!.convertToCoro()
        }
        
        cell.tituloCoroLabel.text = coro!.nombre
        
        if coroEnLista!.tonalidad == "" {
            cell.settleTonalidadButton.setTitle("\(coro!.tonalidad)/\(coro!.ton_alt)", forState: .Normal)
            cell.settleTonalidadButton.tag = coroEnLista!._id
            cell.settleTonalidadButton.setTitleColor(self.view.tintColor, forState: .Normal)
            cell.settleTonalidadButton.hidden = false
            cell.settleTonalidadButton.enabled = true
        } else {
            let tonRapidosArray = lista.ton_rap.componentsSeparatedByString(",")
            let tonLentosArray = lista.ton_lent.componentsSeparatedByString(",")
            if section == 0 {
                if tonRapidosArray.count > 1 {
                    cell.settleTonalidadButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
                    cell.settleTonalidadButton.setTitle(coroEnLista!.tonalidad, forState: .Normal)
                    cell.settleTonalidadButton.hidden = false
                    cell.settleTonalidadButton.enabled = false
                } else {
                    cell.settleTonalidadButton.hidden = true
                }
            } else if section == 1 {
                if tonLentosArray.count > 1 {
                    cell.settleTonalidadButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
                    cell.settleTonalidadButton.setTitle(coroEnLista!.tonalidad, forState: .Normal)
                    cell.settleTonalidadButton.hidden = false
                    cell.settleTonalidadButton.enabled = false
                } else {
                    cell.settleTonalidadButton.hidden = true
                }
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            if indexPath.section == 0 {
                let coro = rapidosMediosArray[indexPath.row]
                rapidosMediosArray.removeAtIndex(indexPath.row)
                databaseManager.deleteCoroEnLista(lista._id, coroId: coro._id, flag: true)
            } else {
                let coro = lentosArray[indexPath.row]
                lentosArray.removeAtIndex(indexPath.row)
                databaseManager.deleteCoroEnLista(lista._id, coroId: coro._id, flag: true)
            }
            
            if indexPath.section == 0 {
                rapidosMediosArray = databaseManager.getAllRowsCoroEnLista(lista._id, whereClause: "\(celContract.COLUMN_VELOCIDAD)='RM'")
            } else {
                lentosArray = databaseManager.getAllRowsCoroEnLista(lista._id, whereClause: "\(celContract.COLUMN_VELOCIDAD)='L'")
            }
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            todosArray = lentosArray + rapidosMediosArray
        }
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        if sourceIndexPath.section == 0 {
            reorderCorosEnLista(rapidosMediosArray, destination: destinationIndexPath.row,source:  sourceIndexPath.row, section: sourceIndexPath.section)
        } else {
            reorderCorosEnLista(lentosArray, destination: destinationIndexPath.row, source: sourceIndexPath.row, section: sourceIndexPath.section)
        }
    }
    
    func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            var row = 0
            if sourceIndexPath.section < proposedDestinationIndexPath.section {
                row = self.tableView(tableView, numberOfRowsInSection: sourceIndexPath.section) - 1
            }
            return NSIndexPath(forRow: row, inSection: sourceIndexPath.section)
        }
        return proposedDestinationIndexPath
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            self.tableView.editing = editing
        } else {
            self.tableView.editing = editing
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showCoroDetailPager" {
            let tabBarController = segue.destinationViewController as? UITabBarController
            let destinationVC = tabBarController?.viewControllers?.first as? CoroDetailWPagerVC
            let secondVC = tabBarController?.viewControllers?.last as? MusicaPagerParentViewController
            
            if let coroIndex = tableView.indexPathForSelectedRow {
                let coro: Coro!
                let coroEnLista: CoroEnLista!
                if coroIndex.section == 0 {
                    coroEnLista = rapidosMediosArray[coroIndex.row]
                    coro = coroEnLista.convertToCoro()
                } else {
                    coroEnLista = todosArray[coroIndex.row]
                    coro = coroEnLista.convertToCoro()
                }
                destinationVC!.coro = coro
                //para la partitura
                secondVC!.coro = coroEnLista
                secondVC!.lista = lista
                navigationItem.title = nil
            }
            
            // hide current tab bar to show other tab bar
            self.tabBarController?.tabBar.hidden = true
            
            self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.PrimaryHidden
            
        } else if segue.identifier == "addCorosToList" {
            if let destination = segue.destinationViewController as? SelectCorosForListViewController {
                destination.listId = lista._id
            }
        }
    }
    
    func reorderCorosEnLista(array: Array<CoroEnLista>, destination: Int, source: Int, section: Int) {
        if source < destination {
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
        
    }
}

extension DetailListViewController: ListaSelectionDelegate {
    func listaSelected(newLista: Lista) {
        lista = newLista
    }
}

