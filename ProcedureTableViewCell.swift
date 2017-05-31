//
//  ProcedureTableViewCell.swift
//  BeTheChef
//
//  Created by Shlok Kapoor on 15/12/16.
//  Copyright © 2016 AppGali. All rights reserved.
//

import UIKit

class ProcedureTableViewCell: UITableViewCell {

    @IBOutlet weak var stepLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(procedure: String) {
        stepLabel.text = procedure
    }

}
