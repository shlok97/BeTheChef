//
//  Item.swift
//  BeTheChef
//
//  Created by Shlok Kapoor on 15/12/16.
//  Copyright © 2016 AppGali. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class User {
    private var _userName: String!
    private var _userKey: String!
    private var _items = [String]()
    private var _recipesPostedKey = [String]()
    private var _recipesLikedKey = [String]()
    private var _recipesPostedByUser = [Recipe]()
    private var _recipesLikedByUser = [Recipe]()
    private var _recommendedRecipes = [Recipe]()
    private var _otherRecommendations = [Recipe]()
    
    let userID = FIRAuth.auth()?.currentUser?.uid
    
    var items: [String] {
        return _items
    }
    var userName: String! {
        return _userName
    }
    var recipesPosted: [String] {
        return _recipesPostedKey
    }
    var recipesPostedByUser: [Recipe] {
        return _recipesPostedByUser
    }
    var recipesLikedByUser: [Recipe] {
        return _recipesLikedByUser
    }
    var recommendedRecipes: [Recipe] {
        return _recommendedRecipes
    }
    var otherRecommendations: [Recipe] {
        return _otherRecommendations
    }
    
    // MARK - Initializers
    
    init () {
        _recommendedRecipes.removeAll()
        _otherRecommendations.removeAll()
    }
    
    init(userKey: String, userName: String) {
        self._userName = userName
        self._userKey = userKey
    }
    
    func addRecipe(recipeKey: String) {
        _recipesPostedKey.append(recipeKey)
    }
    
    func likeRecipe(recipeKey: String) {
        _recipesLikedKey.append(recipeKey)
    }
    
    // MARK: Load Data

    func loadItems() {
        _items.removeAll()
        DataService.ds.REF_USERS.child(userID!).child("Items").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snaps = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snaps {
                    if let ingredientDict = snap.value as? Dictionary<String, String> {
                        if let itemName = ingredientDict["itemName"] {
                            var itemNameVariable = itemName
                            let capitalizedItemName = itemName.capitalized
                            
                            if(capitalizedItemName == "CURD" || capitalizedItemName == "DAHI" || capitalizedItemName == "YOGHURT") {
                                print("Yes")
                                itemNameVariable = "Yogurt"
                            }
                            self._items.append(itemNameVariable)
                            
                        }
                    }
                }
            }
        })
    }
    
    
    func loadRecipes(completion: @escaping (Bool) -> ()) {
            print("LOADED RECIPES")
            var noOfRecipesLoaded = 0
            _recommendedRecipes.removeAll()
            _otherRecommendations.removeAll()
            
            _items.removeAll()
            
            DataService.ds.REF_USERS.child(userID!).child("Items").observeSingleEvent(of: .value, with: { (snapshot) in
                if let snaps = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snaps {
                        if let ingredientDict = snap.value as? Dictionary<String, String> {
                            if let itemName = ingredientDict["itemName"] {
                                self._items.append(itemName)
                            }
                        }
                    }
                    self._otherRecommendations.removeAll()
                    DataService.ds.REF_RECIPES.observeSingleEvent(of: .value, with: { (snapshot) in
                        // Create an object out of every single post in the database
                        debugPrint("calling recipes")
                        if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                            for snap in snapshot {
                                
                                var recipe = Recipe()
                                var isRecipeApproved = false
                                if let recipeDict = snap.value as? Dictionary<String, AnyObject> {
                                    let key = snap.key
                                    recipe = Recipe(recipeKey: key, recipeData: recipeDict)
                                    if(recipeDict["Approved"] as! Int == 1) {
                                        isRecipeApproved = true
                                    }
                                    
                                    if let ingredientDict = recipeDict["ingredients"] as? Dictionary<String, AnyObject> {
                                        for key in ingredientDict.keys {
                                            let ingredientData = ingredientDict[key]
                                            let ingredient = IngredientWithQuantity(ingredientKey: key, ingredientData: ingredientData as! Dictionary<String, String>)
                                            recipe.appendIngredients(ingredient: ingredient)
                                        }
                                    }
                                }
                                
                                if(recipe.numberOfIngredientsNotAvailableInUsersFridge(usersFridge: self._items) == 0) {
                                    if(isRecipeApproved) {
                                        self._recommendedRecipes.append(recipe)
                                    }
                                }
                                else {
                                    if(isRecipeApproved && noOfRecipesLoaded < 70) {
                                        noOfRecipesLoaded += 1
                                        self._otherRecommendations.append(recipe)
                                        print("HOME RECIPE")
                                    }
                                }
                                self._otherRecommendations.reverse()
                                self._otherRecommendations.sort(by: {$0.numberOfIngredientsNotAvailableInUsersFridge(usersFridge: self._items) < $1.numberOfIngredientsNotAvailableInUsersFridge(usersFridge: self._items)})
                                
                                /*
                                DataService.ds.REF_RECIPES.child(snap.key).child("ingredients").observe(.value, with: { (snapshot) in
                                    // Create an object out of every single ingredient in post
                                    debugPrint("calling recipes inside")
                                    if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                                        for snap in snapshot {
                                            if let ingredientDict = snap.value as? Dictionary<String, String> {
                                                let key = snap.key
                                                let ingredient = IngredientWithQuantity(ingredientKey: key, ingredientData: ingredientDict)
                                                recipe.appendIngredients(ingredient: ingredient)
                                            }
                                        }
                                    }
                                    
                                    if(recipe.numberOfIngredientsNotAvailableInUsersFridge(usersFridge: self._items) == 0) {
                                        if(isRecipeApproved) {
                                            self._recommendedRecipes.append(recipe)
                                        }
                                    }
                                    else {
                                        if(isRecipeApproved && noOfRecipesLoaded < 30) {
                                            noOfRecipesLoaded += 1
                                            self._otherRecommendations.append(recipe)
                                            print("HOME RECIPE")
                                        }
                                    }
                                    self._otherRecommendations.sort(by: {$0.numberOfIngredientsNotAvailableInUsersFridge(usersFridge: self._items) < $1.numberOfIngredientsNotAvailableInUsersFridge(usersFridge: self._items)})
                                })
 
                                */
                                
                            }
                        }
                        self._recommendedRecipes.reverse()
                        completion(true)
                    })
                }
            })
        
    }
    
    
    func loadRecipesPostedByUser(completion: @escaping (Bool) -> ()) {
        /*
            _recipesPostedByUser.removeAll()
            DataService.ds.REF_USERS_CURRENT.child("recipesPosted").observeSingleEvent(of: .value, with: { (snapshot) in
                if let snaps = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    self._recipesPostedByUser.removeAll()
                    for snap in snaps {
                        let recipeKey = snap.key
                        //                    print("KEY" + recipeKey)
                        
                        DataService.ds.REF_RECIPES.observeSingleEvent(of: .value, with: {
                            (snapshot) in
                            if let snaps = snapshot.children.allObjects as? [FIRDataSnapshot] {
                                for snap in snaps {
                                    //                                print("KEY" + recipeKey)
                                    if (snap.key == recipeKey) {
                                        var recipe = Recipe()
                                        if let recipeDict = snap.value as? Dictionary<String, AnyObject> {
                                            //                                        print(recipeDict["Title"]!)
                                            recipe = Recipe(recipeKey: recipeKey, recipeData: recipeDict)
                                            if let ingredientDict = recipeDict["ingredients"] as? Dictionary<String, AnyObject> {
                                                for key in ingredientDict.keys {
                                                    
                                                    let ingredientData = ingredientDict[key]
                                                    let ingredient = IngredientWithQuantity(ingredientKey: key, ingredientData: ingredientData as! Dictionary<String, String>)
                                                    recipe.appendIngredients(ingredient: ingredient)
                                                }
                                            }
                                            
                                            if((recipeDict["Approved"] as! Int) == 1) {
                                                self._recipesPostedByUser.append(recipe)
                                                print("POSTED RECIPE2")
                                                
                                            }
                                            
                                            /*
                                            DataService.ds.REF_RECIPES.child(recipeKey).child("ingredients").observe(.value, with: { (snapshot) in
                                                //                                            print(recipeKey)
                                                // Create an object out of every single ingredient in post
                                                if let snaps = snapshot.children.allObjects as? [FIRDataSnapshot] {
                                                    for snap in snaps {
                                                        if let ingredientDict = snap.value as? Dictionary<String, String> {
                                                            let key = snap.key
                                                            let ingredient = IngredientWithQuantity(ingredientKey: key, ingredientData: ingredientDict)
                                                            recipe.appendIngredients(ingredient: ingredient)
                                                        }
                                                    }
                                                }
                                                if((recipeDict["Approved"] as! Int) == 1) {
                                                    self._recipesPostedByUser.append(recipe)
                                                    print("POSTED RECIPE2")
                                                    
                                                }
                                            })
                                            */
                                        }
                                    }
                                }
                            }
                            completion(true)
                        })
                    }
                }
            })
        */
        debugPrint("downloading Recipes posted by user")
        _recipesPostedByUser.removeAll()
        DataService.ds.REF_USERS_CURRENT.child("recipesPosted").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snaps = snapshot.children.allObjects as? [FIRDataSnapshot] {
                self._recipesPostedByUser.removeAll()
                for snap in snaps {
                    let recipeKey = snap.key
                    //                            print("KEY" + recipeKey)
                    DataService.ds.REF_RECIPES.observeSingleEvent(of: .value, with: {
                        (snapshot) in
                        if let snaps = snapshot.children.allObjects as? [FIRDataSnapshot] {
                            for snap in snaps {
                                //                                        print("KEY" + recipeKey)
                                if (snap.key == recipeKey) {
                                    var recipe = Recipe()
                                    
                                    if let recipeDict = snap.value as? Dictionary<String, AnyObject> {
                                        //                                                print(recipeDict["Title"]!)
                                        recipe = Recipe(recipeKey: recipeKey, recipeData: recipeDict)
                                        
                                        if let ingredientDict = recipeDict["ingredients"] as? Dictionary<String, AnyObject> {
                                            for key in ingredientDict.keys {
                                                
                                                let ingredientData = ingredientDict[key]
                                                let ingredient = IngredientWithQuantity(ingredientKey: key, ingredientData: ingredientData as! Dictionary<String, String>)
                                                recipe.appendIngredients(ingredient: ingredient)
                                            }
                                        }
                                        
                                        if((recipeDict["Approved"] as! Int) == 1) {
                                            self._recipesPostedByUser.append(recipe)
                                            print("POSTED RECIPE" + recipe.title)
                                            
                                        }
                                    }
                                }
                            }
                        }
                        if snap == snaps.last {
                            self._recipesPostedByUser.reverse()
                            completion(true)
                        }
                    })
                    
                }
                if(snaps.count == 0) {
                    completion(true)
                }
            }
        })
    }
    
    func loadRecipesLikedByUser(completion: @escaping (Bool) -> ()) {
        
            _recipesLikedByUser.removeAll()
            DataService.ds.REF_USERS_CURRENT.child("likedRecipes").observeSingleEvent(of: .value, with: { (snapshot) in
                if let snaps = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    self._recipesLikedByUser.removeAll()
                    for snap in snaps {
                        let recipeKey = snap.key
                        //                            print("KEY" + recipeKey)
                        DataService.ds.REF_RECIPES.observeSingleEvent(of: .value, with: {
                            (snapshot) in
                            if let snaps = snapshot.children.allObjects as? [FIRDataSnapshot] {
                                for snap in snaps {
                                    //                                        print("KEY" + recipeKey)
                                    if (snap.key == recipeKey) {
                                        var recipe = Recipe()
                                        
                                        if let recipeDict = snap.value as? Dictionary<String, AnyObject> {
                                            //                                                print(recipeDict["Title"]!)
                                            recipe = Recipe(recipeKey: recipeKey, recipeData: recipeDict)
                                            
                                            if let ingredientDict = recipeDict["ingredients"] as? Dictionary<String, AnyObject> {
                                                for key in ingredientDict.keys {
                                                    
                                                    let ingredientData = ingredientDict[key]
                                                    let ingredient = IngredientWithQuantity(ingredientKey: key, ingredientData: ingredientData as! Dictionary<String, String>)
                                                    recipe.appendIngredients(ingredient: ingredient)
                                                }
                                            }
                                            
                                            if((recipeDict["Approved"] as! Int) == 1) {
                                                self._recipesLikedByUser.append(recipe)
                                                print("LIKED RECIPE" + recipe.title)
                                                
                                            }
                                            
                                            
                                            /*
                                            DataService.ds.REF_RECIPES.child(recipeKey).child("ingredients").observe(.value, with: { (snapshot) in
                                                //                                                    print(recipeKey)
                                                // Create an object out of every single ingredient in post
                                                if let snaps = snapshot.children.allObjects as? [FIRDataSnapshot] {
                                                    for snap in snaps {
                                                        if let ingredientDict = snap.value as? Dictionary<String, String> {
                                                            let key = snap.key
                                                            let ingredient = IngredientWithQuantity(ingredientKey: key, ingredientData: ingredientDict)
                                                            recipe.appendIngredients(ingredient: ingredient)
                                                        }
                                                    }
                                                }
                                                if((recipeDict["Approved"] as! Int) == 1) {
                                                    self._recipesLikedByUser.append(recipe)
                                                    print("LIKED TITLE")
                                                    //                                                        print(recipe.title)
                                                }
                                            })
                                        */
                                            
                                        }
                                    }
                                }
                            }
                            
                            if snap == snaps.last {
                                self._recipesLikedByUser.reverse()
                                completion(true)
                            }
                            
                        })
                    }
                    if(snaps.count == 0) {
                        completion(true)
                    }
                }
                
            })
    }
    
    func clearLikedRecipes() {
        self._recipesLikedByUser.removeAll()
    }
    
    init (userKey: String!, userData: Dictionary<String, AnyObject>) {
        self._otherRecommendations.removeAll()
        self._recipesLikedByUser.removeAll()
        self._recipesPostedByUser.removeAll()
        self._recommendedRecipes.removeAll()
        
        self._userKey = userKey
        
        if let userName = userData["Name"] {
            self._userName = userName as! String
        }
        if let items = userData["Items"] {
            self._items = items as! [String]
        }
        if let recipesPosted = userData["RecipesPosted"] {
            self._recipesPostedKey = recipesPosted as! [String]
        }
        if let recipesLiked = userData["RecipesLiked"] {
            self._recipesLikedKey = recipesLiked as! [String]
        }
    }
}
