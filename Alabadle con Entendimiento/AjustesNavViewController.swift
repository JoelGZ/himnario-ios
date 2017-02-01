//
//  AjustesNavViewController.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 1/30/17.
//  Copyright © 2017 Joel García. All rights reserved.
//

import UIKit

class AjustesNavViewController: UINavigationController {
    
    let defaults = UserDefaults.standard

    //MARK: Rotation    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        let isLoginScreenVisible = defaults.bool(forKey: "LOG_SCREEN_VISIBLE")
        if isLoginScreenVisible {
            return .portrait
        } else {
            return .all
        }
    }

}
