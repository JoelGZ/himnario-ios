//
//  CoroDetailWPagerViewController.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 10/22/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import UIKit

class CoroDetailWPagerViewController: UIViewController {        
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
    var coroEnLista: CoroEnLista?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup content of labels
        coroEnLista?.convertToCoro(completion: {(coroResultante: Coro) in
            self.coro = coroResultante
            self.setupViews()
        })
        
        //Prevent screen from dimming
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func setupViews(){
        
        //Localize
        //Titulos 2
        infoGeneralLabel.text = "Informacion General"
        letraCoroTituloLabel.text = "Letra"
        historiaCoroTituloLabel.text = "Historia"
        
        
        //Titulos caracteristicas
        tonalidadTituloLabel.text = "Tonalidad:"
        tonAltTituloLabel.text = "Tonalidad Alternativa:"
        velocidadTituloLabel.text = "Velocidad:"
        tiempoTituloLabel.text = "Tiempo:"
        autorLetraTituloLabel.text = "Autor Letra:"
        autorMusicaTituloLabel.text = "Autor Musica:"
        
        //Cambios dinamicos
        nombreCoroLabel.text = coro!.nombre
        
        numeroCoroLabel.text = String(coro!.id)
        tonalidadLabel.text = "\(coro!.tonalidad.getReadableText()) (\(coro!.tonalidad))"
        if coro!.ton_alt != "" {
            tonAltLabel.text = "\(coro!.ton_alt.getReadableText()) (\(coro!.ton_alt))"
        } else {
            tonAltLabel.text = ""
        }
        
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
            autorLetraLabel.text = "Desconocido"
        } else {
            autorLetraLabel.text = coro!.autorletra
        }
        
        if (coro!.autormusica == "") {
            autorMusicaLabel.text = "Desconocido"
        } else {
            autorMusicaLabel.text = coro!.autormusica
        }
        
        if (coro!.historia != "") {
            self.historiaLabel.text = coro!.historia
        } else {
            self.historiaLabel.isHidden = true
        }
    }
    
    @IBAction func tonAltInfoAction(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Tonalidades Alternativas", message: "Se recomienda siempre cantar los coros en su tonalidad original.", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = self.view.bounds
        self.present(alert, animated: true, completion: nil)
    }
    
}
