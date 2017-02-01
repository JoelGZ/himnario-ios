//
//  NavViewController.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 1/30/17.
//  Copyright © 2017 Joel García. All rights reserved.
//

import UIKit

class NavViewController: UINavigationController {

    //MARK: Rotation    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if self.topViewController is LoginViewController {
            return .portrait
        } else {
            return .all
        }
    }

}
