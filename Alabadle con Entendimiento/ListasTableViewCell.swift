//
//  ListasTableViewCell.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 10/11/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import UIKit

class ListaTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var nombreListaLabel: UILabel!
    @IBOutlet weak var tonalidadListaLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
