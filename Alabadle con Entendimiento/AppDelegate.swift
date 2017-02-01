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
        let spViewController = tabBarController.viewControllers![1] as! UISplitViewController
        let leftNavController = spViewController.viewControllers.first as! UINavigationController
        let masterViewController = leftNavController.topViewController as! ListasTableViewController
        let rightNavController = spViewController.viewControllers.last as! UINavigationController
        let detailViewController = rightNavController.topViewController as! DetailListViewController
        
        spViewController.delegate = self
        
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
                            let listaIDStr = (listaID as! FIRDataSnapshot).key
                            let listaRef = listasDeUsuarioRef.child(listaIDStr)
                            listaRef.observeSingleEvent(of: FIRDataEventType.value, with: {(snap) in
                                let list = Lista(snapshot: snap, listaid: snap.key)
                                detailViewController.lista = list
                            })
                        }
                    }
                }
            })
        }
        
        let pageController = UIPageControl.appearance()
        pageController.pageIndicatorTintColor = UIColor.lightGray
        pageController.currentPageIndicatorTintColor = UIColor.black
        pageController.backgroundColor = UIColor.white
        
        masterViewController.delegate1 = detailViewController
        let navigationController = spViewController.viewControllers[spViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = spViewController.displayModeButtonItem
        
        return true
    }

    // MARK: - Split view
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailListViewController else { return false }
        
        return true
    }
}

