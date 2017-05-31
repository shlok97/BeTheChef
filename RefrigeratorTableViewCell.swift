//
//  RefrigeratorTableViewCell.swift
//  BeTheChef
//
//  Created by Shlok Kapoor on 21/01/17.
//  Copyright © 2017 AppGali. All rights reserved.
//

import UIKit

class RefrigeratorTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ingredientLabel: UILabel!
    @IBOutlet weak var ingredientImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(ingredient: String, itemNumber: Int) {
        ingredientLabel.text = ingredient.capitalized
        ingredientImage.image = UIImage(named: "img_\(itemNumber)")
    }
}
