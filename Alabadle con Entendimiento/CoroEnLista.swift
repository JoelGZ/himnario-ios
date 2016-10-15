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
    
    func convertToCoro(completion:@escaping (_ coro: Coro) -> Void ) {
        let corosRef = FIRDatabase.database().reference().child("coros")
        corosRef.child("\(self.id)").observeSingleEvent(of: FIRDataEventType.value, with: {(snapshot) in
            let coroFIR = Coro(snapshot: snapshot, dbRef: corosRef)
            completion(coroFIR)
        })
    }
}
