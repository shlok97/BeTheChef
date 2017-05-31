//
//  FavouriteButtonView.swift
//  BeTheChef
//
//  Created by Shlok Kapoor on 14/12/16.
//  Copyright © 2016 AppGali. All rights reserved.
//

import UIKit

class FavouriteButtonView: UIButton {
    
    override func awakeFromNib() {
        self.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        self.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 10)
        print("fav button loaded")
    }
}
