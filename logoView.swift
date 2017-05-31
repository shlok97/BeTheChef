//
//  logoView.swift
//  MyRecipeBook
//
//  Created by Shlok Kapoor on 07/12/16.
//  Copyright © 2016 AppGali. All rights reserved.
//

import UIKit

class logoView: UIView {
    override func awakeFromNib() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 5
        let _backgroundColor = UIColor(red: 238, green: 199, blue: 25, alpha: 1)
        self.layer.backgroundColor = _backgroundColor.cgColor
    }
}
