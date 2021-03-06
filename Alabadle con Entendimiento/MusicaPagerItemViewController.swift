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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
        
        activityIndicator.startAnimating()
        partituraImageView.isHidden = true
        scrollView.delegate = self
        
        scrollView.bounds.size.height = UIScreen.main.bounds.height - (defaults.object(forKey: "navBarHeight") as! CGFloat) + 7
        scrollView.bounds.size.width = UIScreen.main.bounds.width
        
        let sName = coro?.sName
        let musicaString = sName?.replacingOccurrences(of: " ", with:"_")
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        let filePath = url.appendingPathComponent("partituras/\(musicaString!).jpg")?.path
        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: filePath!) {
            partituraImageView.image = UIImage(contentsOfFile: filePath!)
            self.partituraImageView.isHidden = false
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        } else {
            storageRef = storage.reference(forURL: "gs://alabadle-con-entendimiento.appspot.com/")
            let sName = self.coro?.sName
            self.musicaString = (sName?.replacingOccurrences(of: " ", with:"_"))!
            let partituraRef = self.storageRef.child("partituras/\(self.musicaString!).jpg")
            partituraRef.data(withMaxSize: 1*1024*1024) {(data, error) -> Void in
                if (error != nil) {
                    // TODO: inform user that something went wrong
                } else {
                    self.partituraImageView.image = UIImage(data: data!)
                    self.partituraImageView.isHidden = false
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                }
            }
        }
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
        let widthScale = scrollViewSize.width / 1277
        let heightScale = scrollViewSize.height / 1652
        
        if landscape {
            minScale = max(widthScale,heightScale)
        } else {
            minScale = min(widthScale, heightScale)
        }
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 2.0
        scrollView.setZoomScale(minScale, animated: false)
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
