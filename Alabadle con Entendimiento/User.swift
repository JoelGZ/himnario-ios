//
//  User.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 10/7/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import UIKit
import FirebaseAuth

struct User {
    
    let uid: String
    let email: String
    
    init(authData: FIRUser) {
        uid = authData.uid
        email = authData.email!
    }
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
    
    func toAnyObject() -> Any {
        var device: String
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            device = "iPhone"
        case .pad:
            device = "iPad"
        case .unspecified:
            device = "Unspecified"
        default:
            device = ""
        }
        
        return [
            "email": email,
            "os-device": device
        ]
    }
}
