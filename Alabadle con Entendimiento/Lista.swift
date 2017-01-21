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
}
