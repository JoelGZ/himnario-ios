//
//  MusicaPagerParentViewController.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 10/21/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import UIKit
import FirebaseDatabase

class MusicaPagerParentViewController: UIViewController, UIPageViewControllerDataSource {
    
    private var pageViewController: UIPageViewController?
    var partiturasArray: Array<String> = []
    var corosArray: Array<Coro> = []
    var coro: CoroEnLista!
    var lista: Lista!
    var index: Int!
    
    var corosEnListaRef: FIRDatabaseReference?
    var lentosRef: FIRDatabaseReference?
    var rapidosMediosRef: FIRDatabaseReference?
    
    var corosEnListaRapidosArray: Array<CoroEnLista> = []
    var corosEnListaLentosArray: Array<CoroEnLista> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        splitViewController!.presentsWithGesture = false
        let defaults = UserDefaults.standard
        defaults.set(Int(navigationController!.navigationBar.bounds.height), forKey: "navBarHeight")
        defaults.set(partiturasArray.count, forKey: "cantidadCoros")
        
        checkReachability()
    }
    
    func checkReachability() {
        //declare this property where it won't go out of scope relative to your listener
        let reachability = Reachability()!
        
        reachability.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async() {
                self.pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "MusicaPager") as? UIPageViewController
                
                self.pageViewController!.dataSource = self
                
                let startVC = self.viewControllerAtIndex(index: self.index) as MusicaPagerItemViewController
                let viewControllers = NSArray(object: startVC)
                
                self.pageViewController!.setViewControllers(viewControllers as? [UIViewController], direction: .forward, animated: true, completion: nil)
                self.pageViewController!.view.frame = CGRect(x: 0, y: self.navigationController!.navigationBar.bounds.height + 8, width: self.view.frame.width, height: self.view.frame.height)
                self.view.addSubview(self.pageViewController!.view)
                self.pageViewController!.didMove(toParentViewController: self)
            }
        }
        
        reachability.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async() {
                let alert = UIAlertController(title: "Sin conexión...", message: "Este contenido solamente está disponible en linea.", preferredStyle: UIAlertControllerStyle.alert)
                let regresarAction = UIAlertAction(title: "Regresar", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in self.goBackWhenNoConnection()
                })
                alert.addAction(regresarAction)
                alert.popoverPresentationController?.sourceView = self.view
                alert.popoverPresentationController?.sourceRect = self.view.bounds
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    func goBackWhenNoConnection() {
        self.tabBarController?.selectedIndex = 0
    }

    
    func loadDataWhenReady(completion:@escaping (_ isReady: Bool) -> Void ) {
        //if both arrays have been set (readyNumber == 2)then indicate it is ready to continue
        var readyNumber = 0
        
        rapidosMediosRef = corosEnListaRef?.child("rapidos-medios")
        lentosRef = corosEnListaRef?.child("lentos")
        
        rapidosMediosRef?.observeSingleEvent(of: FIRDataEventType.value, with: {(rapSnap) in
            var tempArray1 = [CoroEnLista]()
            for coroRMChild in rapSnap.children {
                let coroRMEnLista = CoroEnLista(snapshot: (coroRMChild as! FIRDataSnapshot))
                tempArray1.append(coroRMEnLista)
            }
            self.corosEnListaRapidosArray = tempArray1
            readyNumber += 1
            if readyNumber == 2 {
                completion(true)
            }
        })
        
        lentosRef?.observeSingleEvent(of: FIRDataEventType.value, with: {(lentSnap) in
            var tempArray2 = [CoroEnLista]()
            for coroLentoChild in lentSnap.children {
                let coroLentoEnLista = CoroEnLista(snapshot: (coroLentoChild as! FIRDataSnapshot))
                tempArray2.append(coroLentoEnLista)
            }
            self.corosEnListaLentosArray = tempArray2
            readyNumber += 1
            if readyNumber == 2 {
                completion(true)
            }
        })
    }

    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func viewControllerAtIndex(index: Int) -> MusicaPagerItemViewController {
        
        if ((self.partiturasArray.count == 0) || (index >= self.partiturasArray.count)) {
            return MusicaPagerItemViewController()
        }
        
        let vc: MusicaPagerItemViewController = self.storyboard?.instantiateViewController(withIdentifier: "MusicaItem") as! MusicaPagerItemViewController
        vc.coro = self.corosArray[index]
        vc.imageName = self.partiturasArray[index]
        vc.itemIndex = index
        
        return vc
        
    }
    
    // MARK: PageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! MusicaPagerItemViewController
        var index = vc.itemIndex as Int
        
        if (index == 0 || index == NSNotFound) {
            return nil
        }
        
        index -= 1
        
        return self.viewControllerAtIndex(index: index)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! MusicaPagerItemViewController
        var index = vc.itemIndex as Int
        
        if (index == NSNotFound) {
            return nil
        }
        
        index += 1
        
        if (index == self.partiturasArray.count) {
            return nil
        }
        
        return self.viewControllerAtIndex(index: index)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.partiturasArray.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}
