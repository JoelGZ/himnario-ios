//
//  CoroEnListaTableViewCell.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 10/11/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import UIKit

class CoroEnListaTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tituloCoroLabel: UILabel!
    @IBOutlet weak var settleTonalidadButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
