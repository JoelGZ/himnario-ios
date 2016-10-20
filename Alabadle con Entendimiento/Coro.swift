//
//  Coro.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 10/4/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import Foundation
import Firebase

class Coro: NSObject {
    
    var id: Int
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
    var sName: String
    
    let ref: FIRDatabaseReference?
    let key: String
    
    init(id: Int, orden: Int, nombre: String, cuerpo: String, tonalidad: String, ton_alt: String, velletra: String, tiempo: Int, audio: String, partitura: String, autormusica: String, autorletra: String, cita: String, historia: String, sName: String){
        self.id = id
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
        self.sName = sName
        
        self.ref = nil
        self.key = ""
    }
    
    init(snapshot: FIRDataSnapshot, dbRef: FIRDatabaseReference){
        let dollarSign = "$"
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        
        id = (dbRef.key as NSString).integerValue
        orden = snapshotValue["orden"] as! Int
        nombre = snapshotValue["nombre"] as! String
        cuerpo = snapshotValue["cuerpo"] as! String
        tonalidad = snapshotValue["ton"] as! String
        ton_alt = snapshotValue["ton_alt"] as! String
        if ton_alt == dollarSign {
            ton_alt = ""
        }
        //TODO: CHANGE TO vel_let
        velletra = snapshotValue["vel_letra"] as! String
        tiempo = snapshotValue["tiempo"] as! Int
        audio = snapshotValue["audio"] as! String
        partitura = snapshotValue["partitura"] as! String
        autormusica = snapshotValue["aut_mus"] as! String
        if autormusica == dollarSign {
            autormusica = ""
        }
        autorletra = snapshotValue["aut_let"] as! String
        if autorletra == dollarSign {
            autorletra = ""
        }
        cita = snapshotValue["cita"] as! String
        if cita == dollarSign {
            cita = ""
        }
        historia = snapshotValue["historia"] as! String
        if historia == dollarSign {
            historia = ""
        }
        sName = snapshotValue["sName"] as! String
        ref = snapshot.ref
    }
    
    init(snapshot: FIRDataSnapshot, coroId: Int) {
        let dollarSign = "$"
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        
        id = coroId
        orden = snapshotValue["orden"] as! Int
        nombre = snapshotValue["nombre"] as! String
        cuerpo = snapshotValue["cuerpo"] as! String
        tonalidad = snapshotValue["ton"] as! String
        ton_alt = snapshotValue["ton_alt"] as! String
        if ton_alt == dollarSign {
            ton_alt = ""
        }
        //TODO: CHANGE TO vel_let
        velletra = snapshotValue["vel_letra"] as! String
        tiempo = snapshotValue["tiempo"] as! Int
        audio = snapshotValue["audio"] as! String
        partitura = snapshotValue["partitura"] as! String
        autormusica = snapshotValue["aut_mus"] as! String
        if autormusica == dollarSign {
            autormusica = ""
        }
        autorletra = snapshotValue["aut_let"] as! String
        if autorletra == dollarSign {
            autorletra = ""
        }
        cita = snapshotValue["cita"] as! String
        if cita == dollarSign {
            cita = ""
        }
        historia = snapshotValue["historia"] as! String
        if historia == dollarSign {
            historia = ""
        }
        sName = snapshotValue["sName"] as! String
        ref = snapshot.ref
    }
    
    func isEqual(object: AnyObject?) -> Bool {
        if let coro = object as? Coro {
            return self.nombre == coro.nombre
        } else {
            return false
        }
    }
}
