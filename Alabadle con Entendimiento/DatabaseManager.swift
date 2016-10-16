//
//  DatabaseManager.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 10/12/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class DatabaseManager {
    
    
    let coroContract:CorosContract = CorosContract()
    let listaContract: ListasContract = ListasContract()
    let celContract: CorosEnListaContract = CorosEnListaContract()
    
   /* init() {
        openDatabase()
    }*/
    
    
    let rootRef = FIRDatabase.database().reference()
    var corosRef: FIRDatabaseReference!
    var listasRef: FIRDatabaseReference!
    var usersRef: FIRDatabaseReference!
   // let user: User
    
    init() {
        corosRef = rootRef.child("coros")
        listasRef = rootRef.child("listas")
        usersRef = rootRef.child("users")
        
        let defaults = UserDefaults.standard
        let userEmail = defaults.string(forKey: "USER_EMAIL")
        let userUID = defaults.string(forKey: "USER_UID")
        
      // user = User(uid: userUID!, email: userEmail!)

    }
    
    
    
}
