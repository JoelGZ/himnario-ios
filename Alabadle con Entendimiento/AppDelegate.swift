//
//  AppDelegate.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 9/27/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    var lista: Lista?
    
    override init() {
        FIRApp.configure()
        FIRDatabase.database().persistenceEnabled = true
        let rootRef = FIRDatabase.database().reference()
        let safeRef = rootRef.child("isSafe")
        safeRef.observe(FIRDataEventType.value, with: {(snapshot) in
            let defaults = UserDefaults.standard
            let isSafeToDisplayDb = snapshot.value as! Bool
            defaults.set(Bool(isSafeToDisplayDb), forKey: "SAFE")
        })
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

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Split view
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailListViewController else { return false }
        
        if topAsDetailController.lista == nil || topAsDetailController.lista.id == 10000 {
            return true
        }
        return false
    }
}

