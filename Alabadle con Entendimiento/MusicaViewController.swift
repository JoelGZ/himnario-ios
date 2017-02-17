//
//  MusicaViewController.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 10/5/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseStorage
import FirebaseDatabase

class MusicaViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var partituraImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var coro:Coro?
    var scrollViewWidthPortrait:CGFloat?
    var scrollViewHeightPortrait:CGFloat?
    var flag = false
    var gestureFlag = true
    var contAux = 0
    var vc: Int!
    var audioPlayer: AVAudioPlayer!
    var rootViewController: UIViewController!
    
    let storage = FIRStorage.storage()
    var sName: String?
    var musicaString: String?
    
    // Create a storage reference from our storage service
    var storageRef: FIRStorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        partituraImageView.isHidden = true
        self.scrollView.delegate = self
        
        flag = true
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        sName = coro?.sName
        musicaString = sName?.replacingOccurrences(of: " ", with:"_")
        storageRef = storage.reference(forURL: "gs://alabadle-con-entendimiento.appspot.com/")
       
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
            self.activityIndicator.startAnimating()
            self.activityIndicator.isHidden = false
            checkReachability()
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func checkReachability() {
        //declare this property where it won't go out of scope relative to your listener
        let reachability = Reachability()!
        
        reachability.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async() {
                let partituraRef = self.storageRef.child("partituras/\(self.musicaString!).jpg")
                partituraRef.data(withMaxSize: 1*1024*1024) {(data, error) -> Void in
                    if (error != nil) {
                        // TODO: inform user that something went wrong
                        print(error)
                    } else {
                        self.partituraImageView.image = UIImage(data: data!)
                        self.partituraImageView.isHidden = false
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
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
    
    override func viewWillAppear(_ animated: Bool) {
        rootViewController = self.navigationController?.topViewController   //viewControllers[vc]
        let playBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(self.playSong(sender:)))
        rootViewController!.navigationItem.rightBarButtonItem = playBarButtonItem
        
        if UIDevice.current.orientation.isLandscape {
            setZoomParametersSize(scrollViewSize: scrollView.bounds.size, landscape: true)
            scrollViewWidthPortrait = scrollView.bounds.height
            scrollViewHeightPortrait = scrollView.bounds.width
        } else {
            setZoomParametersSize(scrollViewSize: scrollView.bounds.size, landscape: false)
            scrollViewWidthPortrait = scrollView.bounds.width
            scrollViewHeightPortrait = scrollView.bounds.height
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let aP = audioPlayer {
            aP.stop()
        }
        rootViewController!.navigationItem.rightBarButtonItem = nil
    }
    
    func goBackWhenNoConnection() {
        tabBarController?.selectedIndex = 0
    }
    
    @IBAction func pauseSong(sender: UIBarButtonItem) {
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        let filePath = url.appendingPathComponent("audios/\(musicaString!).mp3")?.path
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: filePath!) {
            let url = NSURL(fileURLWithPath: filePath!)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url as URL, fileTypeHint: nil)
                audioPlayer.prepareToPlay()
                audioPlayer.pause()
                audioPlayer.numberOfLoops = -1
            } catch {
                errorPlayingSong()
            }
        } else {
            let audioRef = storageRef.child("audios/\(musicaString!).mp3")
            
            /* TODO: Need this when partituras have been downloaded and audios haven't
            let reachability = Reachability()
            if reachability?.isReachable {
                
            }*/
            
            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
            audioRef.data(withMaxSize: 1 * 1024 * 1024) { (data, error) -> Void in
                if (error != nil) {
                    self.errorPlayingSong()
                } else {
                    do {
                        self.audioPlayer = try AVAudioPlayer(data: data!)
                        self.audioPlayer.prepareToPlay()
                        self.audioPlayer.pause()
                    } catch {
                        self.errorPlayingSong()
                    }
                }
            }
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
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        let filePath = url.appendingPathComponent("audios/\(musicaString!).mp3")?.path
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: filePath!) {
            let url = NSURL(fileURLWithPath: filePath!)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url as URL, fileTypeHint: nil)
                audioPlayer.prepareToPlay()
                audioPlayer.play()
                audioPlayer.numberOfLoops = -1
            } catch {
                errorPlayingSong()
            }

        } else {
            // Create a reference to the file you want to download
            let audioRef = storageRef.child("audios/\(musicaString!).mp3")
            
            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
            audioRef.data(withMaxSize: 1 * 1024 * 1024) { (data, error) -> Void in
                if (error != nil) {
                    self.errorPlayingSong()
                } else {
                    do {
                        self.audioPlayer = try AVAudioPlayer(data: data!)
                        self.audioPlayer.prepareToPlay()
                        self.audioPlayer.play()
                        self.audioPlayer.numberOfLoops = -1
                    } catch {
                        self.errorPlayingSong()
                    }
                }
            }
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
        scrollView.setZoomScale(minScale, animated: false)
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
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return partituraImageView
    }
}
