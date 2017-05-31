//
//  ItemInFridge.swift
//  BeTheChef
//
//  Created by Shlok Kapoor on 16/12/16.
//  Copyright © 2016 AppGali. All rights reserved.
//

import Foundation

class ItemInFridge {
    private var _itemName = String()
    private var _itemKey = String()
    
    init(itemKey: String, itemName: String) {
        _itemKey = itemKey
        _itemName = itemName
    }
    
    var itemName: String {
        return _itemName
    }
    var itemKey: String {
        return _itemKey
    }
    
    init(itemKey: String, itemDict: Dictionary<String,String>) {
        _itemKey = itemKey
        
        if let itemName = itemDict["itemName"] {
            _itemName = itemName
        }
    }
}
