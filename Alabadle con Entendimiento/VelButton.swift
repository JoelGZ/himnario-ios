//
//  VelButton.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 10/4/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import UIKit

class VelButton: UIButton {
    // Bool property
    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setTitleColor(UIColor(red: 202/255, green: 201/255, blue: 207/255, alpha: 1.0), for: .normal)
                self.backgroundColor = UIColor(red: 22/255, green: 123/255, blue: 254/255, alpha: 1.0)
                self.layer.cornerRadius = 5
                self.layer.borderWidth = 1
                self.layer.borderColor = UIColor(red: 22/255, green: 123/255, blue: 254/255, alpha: 1.0).cgColor
            } else {
                self.setTitleColor(UIColor(red: 22/255, green: 123/255, blue: 254/255, alpha: 1.0), for: .normal)
                self.backgroundColor = UIColor.clear
                self.layer.cornerRadius = 5
                self.layer.borderWidth = 1
                self.layer.borderColor = UIColor(red: 22/255, green: 123/255, blue: 254/255, alpha: 1.0).cgColor
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action: #selector(buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.isChecked = false
    }
    
    func buttonClicked(sender: UIButton) {
        if sender == self {
            if isChecked == true {
                isChecked = false
            } else {
                isChecked = true
            }
        }
    }
}


