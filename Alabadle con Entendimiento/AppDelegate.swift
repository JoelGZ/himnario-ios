//
//  AppDelegate.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 9/27/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    
    override init() {
        FIRApp.configure()
        FIRDatabase.database().persistenceEnabled = true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let tabBarController = self.window!.rootViewController as! UITabBarController
        let splitViewController = tabBarController.viewControllers![1] as! UISplitViewController
        let leftNavController = splitViewController.viewControllers.first as! UINavigationController
        let masterViewController = leftNavController.topViewController as! ListasTableViewController
        let rightNavController = splitViewController.viewControllers.last as! UINavigationController
        let detailViewController = rightNavController.topViewController as! DetailListViewController
        
        
      /*  let databaseManager = DatabaseManager()
       // let listasArray = databaseManager.getAllListas()
        let listasArray = [Lista]()
        if listasArray.isEmpty {
            lista = masterViewController.resultArray.first
        } else {
            lista = listasArray.last as! Lista?
        }
        detailViewController.lista = lista*/
        
        let defaults = UserDefaults.standard
        let userUID = defaults.string(forKey: "USER_UID")
        if userUID != nil {
            let listasDeUsuarioRef = FIRDatabase.database().reference().child("listas/\(userUID!)")
            listasDeUsuarioRef.observeSingleEvent(of: FIRDataEventType.value, with: {
                (snapshot) in
                if snapshot.hasChildren() {
                    var counter = 0
                    for listaID in snapshot.children {
                        counter += 1
                        if counter == Int(snapshot.childrenCount) {     // display last list
                            let listaIDStr = "\((listaID as! FIRDataSnapshot).key)"
                            print(listaIDStr)
                            let listaRef = listasDeUsuarioRef.child(listaIDStr)
                            print(listaRef)
                            listaRef.observe(FIRDataEventType.value, with: {(snap) in
                                print(Int((listaID as! FIRDataSnapshot).key)!)
                                let list = Lista(snapshot: snap, listaid: Int((listaID as! FIRDataSnapshot).key)!)
                                detailViewController.lista = list
                            })
                           /* listaRef.observeSingleEvent(of: FIRDataEventType.value, with: {(snapshotChild) in
                                let lista = Lista(snapshot: snapshotChild, dbRef: listaRef)
                                print(lista.id)
                                detailViewController.lista = lista
                            })*/
                        }
                    }
                }
            })

        }
        
        let pageController = UIPageControl.appearance()
        pageController.pageIndicatorTintColor = UIColor.lightGray
        pageController.currentPageIndicatorTintColor = UIColor.black
        pageController.backgroundColor = UIColor.white
        
        masterViewController.delegate = detailViewController
        
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self
        
        return true
    }

    // MARK: - Split view
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailListViewController else { return false }
        
        if topAsDetailController.lista == nil || topAsDetailController.lista.id == 10000 {
            return true
        }	
        return true
    }
}

