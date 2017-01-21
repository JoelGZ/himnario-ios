//
//  Lista.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 10/11/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Lista {
    
    //MARK: Properties
    var id: String
    var nombreLista: String
    var ton_global: String
    var ton_rap: String
    var ton_lent: String
    
    var key: String
    var ref: FIRDatabaseReference?
    
    init(id: String, nombreLista: String, ton_global: String, ton_rap: String, ton_lent: String){
        
        self.id = id
        self.nombreLista = nombreLista
        self.ton_global = ton_global
        self.ton_rap = ton_rap
        self.ton_lent = ton_lent
        
        self.key = ""
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot, dbRef: FIRDatabaseReference) {
        let dollarSign = "$"
        key = snapshot.key
        
        let snapshotValue = snapshot.value as! [String: AnyObject]
        
        id = dbRef.key
       
        nombreLista = snapshotValue["nombre"] as! String
        ton_global = snapshotValue["ton_global"] as! String
        if ton_global == dollarSign {
            ton_global = ""
        }
        ton_rap = snapshotValue["ton_rap"] as! String
        if ton_rap == dollarSign {
            ton_rap = ""
        }
        ton_lent = snapshotValue["ton_lent"] as! String
        if ton_lent == dollarSign {
            ton_lent = ""
        }
        
        ref = snapshot.ref
    }
    
    init(snapshot: FIRDataSnapshot, listaid: String) {
        let dollarSign = "$"
        key = snapshot.key
        
        let snapshotValue = snapshot.value as! [String: AnyObject]
        
        id = listaid
        
        nombreLista = snapshotValue["nombre"] as! String
        ton_global = snapshotValue["ton_global"] as! String
        if ton_global == dollarSign {
            ton_global = ""
        }
        ton_rap = snapshotValue["ton_rap"] as! String
        if ton_rap == dollarSign {
            ton_rap = ""
        }
        ton_lent = snapshotValue["ton_lent"] as! String
        if ton_lent == dollarSign {
            ton_lent = ""
        }
        
        ref = snapshot.ref
    }
    
    func toString(listaURL: FIRDatabaseReference) -> String{
        
        var text = "\(self.nombreLista.uppercased())\nTonalidad: \(self.ton_global)\n------------\nRAPIDOS\n"
        
        loadData(listaURL: listaURL){
            (rapMedText: String, lentText: String) in
            text += rapMedText
            text += "------------\nLENTOS\n"
            text += lentText
        }
        
        text += "\nCreada con la Aplicación Alabadle con Entendimiento."
        
        return text
    }
    
    func loadData(listaURL: FIRDatabaseReference, completion:@escaping (_ rapMedText: String, _ lentText: String) -> Void){
        
        var rapMedText = ""
        var lentText = ""
        let lentosRef = listaURL.child("lentos")
        let rapidosMediosRef = listaURL.child("rapidos-medios")
        
        //if both arrays have been set (readyNumber == 2)then indicate it is ready to continue
        var readyNumber = 0
        var rapidosCounter = 0
        var lentosCounter = 0
        rapidosMediosRef.observeSingleEvent(of: FIRDataEventType.value, with: {(rapSnap) in
            for coroRMChild in rapSnap.children {
                let coroRMEnLista = CoroEnLista(snapshot: (coroRMChild as! FIRDataSnapshot))
                rapMedText += "- \(coroRMEnLista.nombre)\n"
                rapidosCounter += 1
                if readyNumber == 2 && rapidosCounter == Int(rapSnap.childrenCount) {
                    completion(rapMedText, lentText)
                }
            }
            readyNumber += 1
        })
        
        lentosRef.observeSingleEvent(of: FIRDataEventType.value, with: {(lentSnap) in
            for coroLentoChild in lentSnap.children {
                let coroLentoEnLista = CoroEnLista(snapshot: (coroLentoChild as! FIRDataSnapshot))
                lentText += "- \(coroLentoEnLista.nombre)\n"
                lentosCounter += 1
                if readyNumber == 2 && lentosCounter == Int(lentSnap.childrenCount) {
                    completion(rapMedText, lentText)
                }
            }
            readyNumber += 1
        })
    
    }

}
