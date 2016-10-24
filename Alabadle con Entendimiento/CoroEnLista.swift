//
//  CoroEnLista.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 10/11/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import Foundation
import FirebaseDatabase

class CoroEnLista{
    var id: Int
    var orden: Int
    var nombre: String
    var velocidad: String
    var tonalidad: String
    
    init(id: Int, orden: Int, nombre: String, velocidad: String, tonalidad: String) {
        self.id = id
        self.orden = orden
        self.nombre = nombre
        self.velocidad = velocidad
        self.tonalidad = tonalidad
    }
    
    init(snapshot: FIRDataSnapshot){
        let snapshotValue = snapshot.value as! [String: AnyObject]
        
        self.id = (snapshot.key as NSString).integerValue
        self.orden = snapshotValue["orden"] as! Int
        self.nombre = snapshotValue["nombre"] as! String
        self.velocidad = snapshot.key == "lentos" ? "L": "RM"
        self.tonalidad = snapshotValue["ton"] as! String
    }
    
    func convertToCoro(completion:@escaping (_ coro: Coro) -> Void ) {
        let corosRef = FIRDatabase.database().reference().child("coros")
        let coroRef = corosRef.child(String(self.id))

        coroRef.observeSingleEvent(of: FIRDataEventType.value, with: {(snapshot) in
            let coroFIR = Coro(snapshot: snapshot, dbRef: corosRef)
            completion(coroFIR)
        })
    }
}
