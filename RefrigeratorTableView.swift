//
//  RefrigeratorTableView.swift
//  BeTheChef
//
//  Created by Shlok Kapoor on 21/01/17.
//  Copyright © 2017 AppGali. All rights reserved.
//

import Foundation
import UIKit

class RefrigeratorTableView: UITableView {
    override func awakeFromNib() {
        let borderColor = UIColor.black
        self.layer.cornerRadius = 15.0
        self.layer.borderColor = borderColor.cgColor
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 5
    }
}
