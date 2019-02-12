//
//  CoroDetailViewController.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 10/5/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseStorage
import FirebaseDatabase

class CoroDetailViewController: UIViewController, UIAlertViewDelegate {
    
    //MARK: Properties
    @IBOutlet weak var nombreCoroLabel: UILabel!
    @IBOutlet weak var numeroCoroLabel: UILabel!
    @IBOutlet weak var infoGeneralLabel: UILabel!
    @IBOutlet weak var tonalidadTituloLabel: UILabel!
    @IBOutlet weak var tonalidadLabel: UILabel!
    @IBOutlet weak var tonAltTituloLabel: UILabel!
    @IBOutlet weak var tonAltLabel: UILabel!
    @IBOutlet weak var velocidadTituloLabel: UILabel!
    @IBOutlet weak var velocidadLabel: UILabel!
    @IBOutlet weak var tiempoTituloLabel: UILabel!
    @IBOutlet weak var tiempoLabel: UILabel!
    @IBOutlet weak var letraCoroTituloLabel: UILabel!
    @IBOutlet weak var letraCoroLabel: UILabel!
    @IBOutlet weak var historiaCoroTituloLabel: UILabel!
    @IBOutlet weak var citaTituloLabel: UILabel!
    @IBOutlet weak var citaLabel: UILabel!
    @IBOutlet weak var autorLetraTituloLabel: UILabel!
    @IBOutlet weak var autorLetraLabel: UILabel!
    @IBOutlet weak var autorMusicaTituloLabel: UILabel!
    @IBOutlet weak var autorMusicaLabel: UILabel!
    @IBOutlet weak var historiaLabel: UILabel!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    // Coro que viene del table view
    var coro:Coro?
    var audioPlayer: AVAudioPlayer!
    var rootViewController: UIViewController!
    
    let storage = FIRStorage.storage()
    var sName: String?
    var musicaString: String?
    
    // Create a storage reference from our storage service
    var storageRef: FIRStorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sName = coro?.sName
        musicaString = sName?.replacingOccurrences(of: " ", with:"_")
        storageRef = storage.reference(forURL: "gs://alabadle-con-entendimiento.appspot.com/")
        
        //setup content of labels
        self.setupViews()
        
        //Prevent screen from dimming
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        if let aP = audioPlayer {
            aP.stop()
        }
       // rootViewController!.navigationItem.rightBarButtonItem = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        rootViewController = self.navigationController?.topViewController   
        let playBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(self.playSong(sender:)))
        rootViewController!.navigationItem.rightBarButtonItem = playBarButtonItem
    }
    
    func setupViews(){
        
        //Localize
        //Titulos 2
        infoGeneralLabel.text = "Informacion General"
        letraCoroTituloLabel.text = "Letra"
        historiaCoroTituloLabel.text = "Historia"
        
        
        //Titulos caracteristicas
        tonalidadTituloLabel.text = "Tonalidad:"
        //tonAltTituloLabel.text = "Tonalidad Alternativa:"
        velocidadTituloLabel.text = "Velocidad:"
        tiempoTituloLabel.text = "Tiempo:"
        autorLetraTituloLabel.text = "Autor Letra:"
        autorMusicaTituloLabel.text = "Autor Musica:"
        
        //Cambios dinamicos
        nombreCoroLabel.text = coro!.nombre
        
        tonalidadLabel.text = "\(coro!.tonalidad.getReadableText()) (\(coro!.tonalidad))"
       /*if coro!.ton_alt != "" {
            tonAltLabel.text = "\(coro!.ton_alt.getReadableText()) (\(coro!.ton_alt))"
        } else {
            tonAltLabel.text = ""
        }*/
        
        velocidadLabel.text = coro!.velletra.getReadableText()
        tiempoLabel.text = String(coro!.tiempo)
        
        letraCoroLabel.lineBreakMode = .byWordWrapping
        letraCoroLabel.numberOfLines = 0
        letraCoroLabel.text = coro!.cuerpo
        
        if (coro!.cita == "") {
            citaTituloLabel.isHidden = true
            citaLabel.isHidden = true
        } else {
            citaTituloLabel.text = "Cita Biblica:"
            citaLabel.text = coro!.cita
        }
        
        if (coro!.autorletra == "") {
            autorLetraLabel.text = "Anónimo"
        } else {
            autorLetraLabel.text = coro!.autorletra
        }
        
        if (coro!.autormusica == "") {
            autorMusicaLabel.text = "Anónimo"
        } else {
            autorMusicaLabel.text = coro!.autormusica
        }
        
        if (coro!.historia != "") {
            self.historiaLabel.text = coro!.historia
        } else {
            self.historiaLabel.isHidden = true
        }
    }
    /*
    @IBAction func tonAltInfoAction(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Tonalidades Alternativas", message: "Se recomienda siempre cantar los coros en su tonalidad original.", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = self.view.bounds
        self.present(alert, animated: true, completion: nil)
    }*/
    
    
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
}


