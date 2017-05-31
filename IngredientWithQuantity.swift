//
//  IngredientWithQuantity.swift
//  BeTheChef
//
//  Created by Shlok Kapoor on 15/12/16.
//  Copyright © 2016 AppGali. All rights reserved.
//

import Foundation

class IngredientWithQuantity {
    private var _quantity: String!
    private var _ingredient: String!
    private var _ingredientKey: String!
    private var _isOptional: Bool!
    
    init(quantity: String, ingredient: String, isOptional: Bool) {
        _quantity = quantity
        _ingredient = ingredient
        _isOptional = isOptional
    }
    init(ingredientKey: String, ingredientData: Dictionary<String, String>) {
        
        self._ingredientKey = ingredientKey
        
        if let quantity = ingredientData["Quantity"] {
            self._quantity = quantity
        }
        
        if let ingredient = ingredientData["Ingredient"] {
            self._ingredient = ingredient
        }
        
        if let isOptional = ingredientData["isOptional"] {
            if(isOptional == "true") {
                
                self._isOptional = true
            }
            else {
                self._isOptional = false
            }
            //print(self._isOptional)
        }
    }
    var ingredientKey: String! {
        return _ingredientKey
    }
    var quantity: String! {
        return _quantity
    }
    var ingredient: String! {
        return _ingredient
    }
    var isOptional: Bool {
        return _isOptional
    }
    var ingredientWithQuantity: String! {
        return _quantity + " " + _ingredient
    }
}
