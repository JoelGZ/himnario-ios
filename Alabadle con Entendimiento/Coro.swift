//
//  Coro.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 10/4/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import Foundation

class Coro: NSObject {
    
    var _id: Int
    var orden: Int
    var nombre: String
    var cuerpo: String
    var tonalidad: String
    var ton_alt: String
    var velletra: String
    var tiempo: Int
    var audio: String
    var partitura: String
    var autormusica: String
    var autorletra: String
    var cita: String
    var historia: String
    var searchableName: String
    
    init(_id: Int, orden: Int, nombre: String, cuerpo: String, tonalidad: String, ton_alt: String, velletra: String, tiempo: Int, audio: String, partitura: String, autormusica: String, autorletra: String, cita: String, historia: String, searchableName: String){
        self._id = _id
        self.orden = orden
        self.nombre = nombre
        self.cuerpo = cuerpo
        self.tonalidad = tonalidad
        self.ton_alt = ton_alt
        self.velletra = velletra
        self.tiempo = tiempo
        self.audio = audio
        self.partitura = partitura
        self.autormusica = autormusica
        self.autorletra = autorletra
        self.cita = cita
        self.historia = historia
        self.searchableName = searchableName
    }
    
    func isEqual(object: AnyObject?) -> Bool {
        if let coro = object as? Coro {
            return self.nombre == coro.nombre
        } else {
            return false
        }
    }
}
