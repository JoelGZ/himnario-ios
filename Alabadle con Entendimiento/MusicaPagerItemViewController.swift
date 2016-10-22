//
//  MusicaPagerItemViewController.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 10/21/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.bounds.size.height = UIScreen.main.bounds.height - (defaults.object(forKey: "navBarHeight") as! CGFloat) + 7
        scrollView.bounds.size.width = UIScreen.main.bounds.width
        
        setZoomParametersSize(scrollViewSize: scrollView.bounds.size, landscape: UIDevice.current.orientation.isLandscape)
        
        scrollView.contentOffset.y = 0
        self.partituraImageView.image = UIImage(named: self.imageName)
        flag = true
        scrollView.delegate = self
        
        setMyPageControl(fl: true)
        configurePageControl()
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
        let widthScale = scrollViewSize.width / 613
        let heightScale = scrollViewSize.height / 793
        
        if landscape {
            minScale = max(widthScale,heightScale)
        } else {
            minScale = min(widthScale, heightScale)
        }
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 2.0
        scrollView.zoomScale = minScale
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
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return partituraImageView
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        pageControl.currentPage = Int(itemIndex)
    }
}
