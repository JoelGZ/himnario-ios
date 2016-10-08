//
//  MusicaViewController.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 10/5/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import UIKit
import AVFoundation

class MusicaViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var partituraImageView: UIImageView!
    
    var coro:Coro?
    var scrollViewWidthPortrait:CGFloat?
    var scrollViewHeightPortrait:CGFloat?
    var flag = false
    var gestureFlag = true
    var contAux = 0
    var vc: Int!
    var audioPlayer: AVAudioPlayer!
    var rootViewController: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.current.orientation.isLandscape
        {
            setZoomParametersSize(scrollViewSize: scrollView.bounds.size, landscape: true)
            scrollViewWidthPortrait = scrollView.bounds.height
            scrollViewHeightPortrait = scrollView.bounds.width
        } else {
            setZoomParametersSize(scrollViewSize: scrollView.bounds.size, landscape: false)
            scrollViewWidthPortrait = scrollView.bounds.width
            scrollViewHeightPortrait = scrollView.bounds.height
        }
        
        scrollView.delegate = self
        //partituraImageView.image = UIImage(named: coro!.musica)
        print("Partitura: \(coro!.partitura)")
        let url = URL(string: coro!.partitura)
        let data = try? Data(contentsOf: url!)
        partituraImageView.image = UIImage(data: data!)
        setZoomParametersSize(scrollViewSize: scrollView.bounds.size, landscape: UIDevice().orientation.isLandscape)
        flag = true
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        rootViewController = self.navigationController?.topViewController   //viewControllers[vc]
        let playBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(self.playSong(sender:)))
        rootViewController!.navigationItem.rightBarButtonItem = playBarButtonItem
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let aP = audioPlayer {
            aP.stop()
        }
        rootViewController!.navigationItem.rightBarButtonItem = nil
    }
    
    @IBAction func pauseSong(sender: UIBarButtonItem) {
        //let path = Bundle.main.pathForResource(coro?.musica, ofType: "mp3")
        let path = Bundle.main.path(forResource: "", ofType: "mp3")
        if let thePath = path {
            let url = NSURL(fileURLWithPath: thePath)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url as URL, fileTypeHint: nil)
                audioPlayer.pause()
            } catch {
                errorPlayingSong()
            }
        } else {
            errorPlayingSong()
        }
        let newBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.play, target: self, action: #selector(self.playSong(sender:)))
        rootViewController!.navigationItem.rightBarButtonItem = newBarButton
    }
    
    @IBAction func imageTapped(sender: UITapGestureRecognizer) {
        if gestureFlag {
            tabBarController?.tabBar.isHidden = true
            self.navigationController?.isNavigationBarHidden = true
            gestureFlag = false
        } else {
            tabBarController?.tabBar.isHidden = false
            self.navigationController?.isNavigationBarHidden = false
            gestureFlag = true
        }
        
    }
    @IBAction func playSong(sender: UIBarButtonItem) {
     //   let path = Bundle.main.pathForResource(coro?.musica, ofType: "mp3")
        let path = Bundle.main.path(forResource: "", ofType: "mp3")
        if let thePath = path {
            let url = NSURL(fileURLWithPath: thePath)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url as URL, fileTypeHint: nil)
                audioPlayer.prepareToPlay()
                audioPlayer.play()
                audioPlayer.numberOfLoops = -1
            } catch {
                errorPlayingSong()
            }
        } else {
            errorPlayingSong()
        }
        let newBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.pause, target: self, action: #selector(self.pauseSong(sender:)))
        rootViewController!.navigationItem.rightBarButtonItem = newBarButton
    }
    
    func errorPlayingSong() {
        let alert = UIAlertController(title: "Error", message: "Lo sentimos. Este audio no esta disponible o no puede ser ejecutado.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func setZoomParametersSize(scrollViewSize: CGSize, landscape: Bool) {
        
        let imageSize = partituraImageView.bounds.size
        let widthScale = scrollViewSize.width / imageSize.width
        let heightScale = scrollViewSize.height / imageSize.height
        
        var minScale:CGFloat
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if flag {
            if UIDevice.current.orientation.isLandscape {
                setZoomParametersSize(scrollViewSize: CGSize(width: scrollViewHeightPortrait!, height: scrollViewWidthPortrait!), landscape: true)
                scrollView.contentOffset.y = 0
            } else {
                setZoomParametersSize(scrollViewSize: CGSize(width: scrollViewWidthPortrait!, height: scrollViewHeightPortrait!), landscape: false)
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        if contAux < 2 {
            if UIDevice.current.orientation.isLandscape {
                setZoomParametersSize(scrollViewSize: scrollView.bounds.size, landscape: true)
                scrollViewWidthPortrait = scrollView.bounds.height
                scrollViewHeightPortrait = scrollView.bounds.width
            } else {
                setZoomParametersSize(scrollViewSize: scrollView.bounds.size, landscape: false)
                scrollViewWidthPortrait = scrollView.bounds.width
                scrollViewHeightPortrait = scrollView.bounds.height
            }
            contAux += 1
        }
    }
}

extension MusicaViewController: UIScrollViewDelegate {
    private func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return partituraImageView
    }
}
