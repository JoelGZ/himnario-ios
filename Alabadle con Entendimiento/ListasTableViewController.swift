//
//  ListasTableViewController.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 10/11/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import UIKit

protocol ListaSelectionDelegate: class {
    func listaSelected(newLista: Lista)
}

class ListasTableViewController: UITableViewController,UISplitViewControllerDelegate {
    
    @IBOutlet weak var navBar: UINavigationItem!
    var resultArray: Array<Lista> = [Lista(_id: 10000, nombreLista: "", ton_global: "", ton_rap: "", ton_lent: "", archivo: "")]
   // var databaseManager: DatabaseManager?
    var resultNumber: Int?
    var noListView: UIView?
    var label: UILabel?
    var flag = false
    var detailViewController: DetailListViewController?
    
    weak var delegate: ListaSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: localize
        navBar.title = "Mis Listas"
        flag = true
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        loadListasData()
        splitViewController!.delegate = self
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailListViewController
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        loadListasData()
        self.tableView.reloadData()
    }
    
    
    func loadListasData() -> Int{
        databaseManager = DatabaseManager()
        resultArray = (databaseManager?.getAllListas())!
        return resultArray.count
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
            databaseManager?.deleteLista(lista._id)
            resultArray.remove(at: indexPath.row)
            if indexPath.row != 0 {
                self.delegate?.listaSelected(newLista: resultArray[indexPath.row - 1])
            } else {
                self.detailViewController?.setupNoListView()
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            if resultArray.count == 0 {
                if let detailViewController = self.delegate as? DetailListViewController{
                    detailViewController.lista = Lista(_id: 10000, nombreLista: "", ton_global: "", ton_rap: "", ton_lent: "", archivo: "")
                    detailViewController.setupNoListView()
                }
            }
        }

    }
    
    //MARK: UISplitViewControllerDelegate
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        if resultArray.first?._id == 10000 {
            return true
        }
        return true
    }
}

