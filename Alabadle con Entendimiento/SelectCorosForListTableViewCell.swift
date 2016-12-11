//
//  SelectCorosForListTableViewCell.swift
//  Alabadle con Entendimiento
//
//  Created by Joel García on 10/18/16.
//  Copyright © 2016 Joel García. All rights reserved.
//

import UIKit

class SelectCorosForListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nombreCoroLabel: UILabel!
    @IBOutlet weak var velocidadLabel: UILabel!
    @IBOutlet weak var tonalidadLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

