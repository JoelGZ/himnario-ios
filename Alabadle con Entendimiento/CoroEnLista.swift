//
//  CoroEnLista.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 10/11/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import Foundation

class CoroEnLista{
    var _id: Int
    var orden: Int
    var nombre: String
    var velocidad: String
    var tonalidad: String
    
    init(_id: Int, orden: Int, nombre: String, velocidad: String, tonalidad: String) {
        self._id = _id
        self.orden = orden
        self.nombre = nombre
        self.velocidad = velocidad
        self.tonalidad = tonalidad
    }
    
    func convertToCoro() -> Coro {
        let databaseManager = DatabaseManager()
        return databaseManager.getCoroByID(self._id)
    }
}
