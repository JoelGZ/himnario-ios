//
//  RootTabBarViewController.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 1/30/17.
//  Copyright © 2017 Joel García. All rights reserved.
//

import UIKit

class RootTabBarViewController: UITabBarController {

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        let navController = self.viewControllers![0] as! NavViewController
        let ajustesNavController = self.viewControllers![2] as! AjustesNavViewController
        if navController.supportedInterfaceOrientations == .portrait || ajustesNavController.supportedInterfaceOrientations == .portrait {
            return .portrait
        } else {
            return .all
        }
    }
}
