//
//  CategoryPickerView.swift
//  BeTheChef
//
//  Created by Shlok Kapoor on 26/12/16.
//  Copyright © 2016 AppGali. All rights reserved.
//

import UIKit

class CategoryPickerView: UIPickerView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
    }
}
