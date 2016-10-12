//
//  Lista.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 10/11/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import Foundation

class Lista {
    
    let databaseManager: DatabaseManager = DatabaseManager()
    
    //MARK: Properties
    var _id: Int
    var nombreLista: String
    var ton_global: String
    var ton_rap: String
    var ton_lent: String
    var archivo: String
    
    init(_id: Int, nombreLista: String, ton_global: String, ton_rap: String, ton_lent: String, archivo: String){
        
        self._id = _id
        self.nombreLista = nombreLista
        self.ton_global = ton_global
        self.ton_rap = ton_rap
        self.ton_lent = ton_lent
        self.archivo = archivo
        
    }
    
    func toString() -> String{
        let databaseManager = DatabaseManager()
        let celContract = CorosEnListaContract()
        var text = "\(self.nombreLista.uppercaseString)\nTonalidad: \(self.ton_global)\n------------\nRAPIDOS\n"
        let whereRapidos = "\(celContract.COLUMN_VELOCIDAD)='RM'"
        let whereLentos = "\(celContract.COLUMN_VELOCIDAD)='L'"
        let rapidosArray = databaseManager.getAllRowsCoroEnLista(self._id, whereClause: whereRapidos)
        let lentosArray = databaseManager.getAllRowsCoroEnLista(self._id, whereClause: whereLentos)
        for coro in rapidosArray {
            text += "- \(coro.nombre)\n"
        }
        text += "------------\nLENTOS\n"
        for coro in lentosArray {
            text += "- \(coro.nombre)\n"
        }
        
        text += "\nCreada con la Aplicación Alabadle con Entendimiento."
        
        return text
    }
    
}
