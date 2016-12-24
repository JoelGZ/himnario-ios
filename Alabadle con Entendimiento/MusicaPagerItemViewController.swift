//
//  MusicaPagerItemViewController.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 10/21/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import UIKit
import FirebaseStorage

class MusicaPagerItemViewController: UIViewController {
    
    @IBOutlet var partituraImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - Variables
    var itemIndex: Int!
    var imageName: String!
    var coro:Coro?
    var flag = false
    var minScale:CGFloat!
    var pageControl: UIPageControl!
    let defaults = UserDefaults.standard
    
    let storage = FIRStorage.storage()
    
    // Create a storage reference from our storage service
    var storageRef: FIRStorageReference!
    var musicaString: String!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        partituraImageView.isHidden = true
        scrollView.delegate = self
        
        scrollView.bounds.size.height = UIScreen.main.bounds.height - (defaults.object(forKey: "navBarHeight") as! CGFloat) + 7
        scrollView.bounds.size.width = UIScreen.main.bounds.width
        
        storageRef = storage.reference(forURL: "gs://alabadle-con-entendimiento.appspot.com/")
        
        checkReachability()
        scrollView.contentOffset.y = 0
        
        flag = true
        
        setMyPageControl(fl: true)
        configurePageControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if UIDevice.current.orientation.isLandscape {
            setZoomParametersSize(scrollViewSize: scrollView.bounds.size, landscape: true)
        } else {
            setZoomParametersSize(scrollViewSize: scrollView.bounds.size, landscape: false)
        }
    }
    
    func checkReachability() {
        //declare this property where it won't go out of scope relative to your listener
        let reachability = Reachability()!
        
        reachability.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async() {
                let sName = self.coro?.sName
                self.musicaString = (sName?.replacingOccurrences(of: " ", with:"_"))!
                let partituraRef = self.storageRef.child("partituras/\(self.musicaString!).jpg")
                partituraRef.data(withMaxSize: 1*1024*1024) {(data, error) -> Void in
                    if (error != nil) {
                        // TODO: inform user that something went wrong
                    } else {
                        self.partituraImageView.image = UIImage(data: data!)
                        self.partituraImageView.isHidden = false
                    }
                }
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
        tabBarController?.selectedIndex = 0
    }
    
    func setMyPageControl(fl: Bool) {
        
        if scrollView.zoomScale == minScale || flag {
            if UIDevice.current.orientation.isLandscape {
                pageControl = UIPageControl(frame: CGRect(x: UIScreen.main.bounds.size.width/2 - 100,y: 10,width: 200, height: 20))

            } else {
                pageControl = UIPageControl(frame: CGRect(x:UIScreen.main.bounds.size.width/2 - 100,y: UIScreen.main.bounds.size.height - ((defaults.object(forKey: "tabBarHeight") as! CGFloat) + (defaults.object(forKey: "navBarHeight") as! CGFloat) + 30),width: 200,height: 20))
            }
            pageControl.isHidden = false
        }
    }
    
    func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView?) {
        pageControl.isHidden = true
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        setMyPageControl(fl: false)
    }
    
    func setZoomParametersSize(scrollViewSize: CGSize, landscape: Bool) {
        let imageSize = partituraImageView.bounds.size
        //let widthScale = scrollViewSize.width / 613
        let widthScale = scrollViewSize.width / 1277
        //let heightScale = scrollViewSize.height / 793
        let heightScale = scrollViewSize.height / 1652
        dump("image \(imageSize)")
        dump("scroll \(scrollViewSize)")
        
        if landscape {
            minScale = max(widthScale,heightScale)
        } else {
            minScale = min(widthScale, heightScale)
        }
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 2.0
        scrollView.setZoomScale(minScale, animated: false)
        print(scrollView.zoomScale)
        print(minScale)
        scrollView.contentOffset.y = 0
    }
    
    
    func configurePageControl() {
        self.pageControl.numberOfPages = defaults.object(forKey: "cantidadCoros") as! Int
        self.pageControl.currentPage = itemIndex
        self.pageControl.tintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.lightGray
        self.pageControl.currentPageIndicatorTintColor = UIColor.darkGray
        self.scrollView.addSubview(pageControl)
    }
    
    override func viewWillLayoutSubviews() {
        self.pageControl.removeFromSuperview()
        scrollView.bounds.size.height = UIScreen.main.bounds.height - (defaults.object(forKey: "navBarHeight") as! CGFloat) + 7
        scrollView.bounds.size.width = UIScreen.main.bounds.width
        
        if UIDevice.current.orientation.isLandscape {
            self.setZoomParametersSize(scrollViewSize: scrollView.bounds.size, landscape: true)
        } else {
            setZoomParametersSize(scrollViewSize: scrollView.bounds.size, landscape: false)
        }
        setMyPageControl(fl: false)
        configurePageControl()
    }
}

extension MusicaPagerItemViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return partituraImageView
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(itemIndex)
    }
}
