//
//  Recipe.swift
//  BeTheChef
//
//  Created by Shlok Kapoor on 14/12/16.
//  Copyright © 2016 AppGali. All rights reserved.
//

import Foundation
import Firebase
import Kingfisher

class Recipe {
    private var _title: String!
    private var _description: String!
    private var _likes: Int!
    private var _ingredients: [IngredientWithQuantity] = []
    private var _pictureUrl: String!
    private var _procedure: [String] = []
    private var _recipeID: String!
    private var _postedByUserName: String!
    private var _postedByUserKey: String!
    private var _recipeImage: UIImage?
    private var _liked = false
    
    var title: String {
        return _title
    }
    
    var description: String {
        return _description
    }
    
    var likes: Int {
        return _likes
    }
    
    var ingredients: [IngredientWithQuantity] {
        return _ingredients
    }
    
    var pictureUrl: String {
        return _pictureUrl
    }
    
    var procedure: [String] {
        return _procedure
    }
    
    var recipeID: String {
        return _recipeID
    }
    
    var postedByUserName: String {
        return _postedByUserName
    }
    
    var postedByUserKey: String {
        return _postedByUserKey
    }
    var recipeImage: UIImage? {
        return _recipeImage
    }
    var liked: Bool {
        return _liked
    }
    
    init(title: String, likes: Int, description: String, ingredients: [IngredientWithQuantity], pictureUrl: String, procedure: [String], postedByUserKey: String, postedByUserName: String) {
        self._likes = likes
        self._procedure = procedure
        self._pictureUrl = pictureUrl
        self._description = description
        self._ingredients = ingredients
        self._title = title
        self._postedByUserKey = postedByUserKey
        self._postedByUserName = postedByUserName
        
//        if let img = RecipesViewController.imageCache.object(forKey: pictureUrl as NSString) {
//                self._recipeImage = img
//            }
//            
//        else {
//            let ref = FIRStorage.storage().reference(forURL: pictureUrl)
//                ref.data(withMaxSize: 2*1024*1024, completion: { (data, error) in
//                    if(error != nil) {
//                        print("Error downloading image in recipe")
//                        if let img = RecipesViewController.imageCache.object(forKey: unableToDownloadImageURL as NSString) {
//                            self._recipeImage = img
//                        }
//                    }
//                    
//                    else {
//                        print("image downloaded successfully in recipe")
//                        if let imageData = data {
//                            if let image = UIImage(data: imageData) {
//                                self._recipeImage = image
//                                RecipesViewController.imageCache.setObject(image, forKey: pictureUrl as NSString)
//                            }
//                        }
//                    }
//                    
//                    recipesLoaded.append(self)
//                    
//                    let likesRef = DataService.ds.REF_USERS_CURRENT.child("likedRecipes").child(self.recipeID)
//                    likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
//                        if let _ = snapshot.value as? NSNull {
//                            self._liked = false
//                        }
//                        else {
//                            self._liked = true
//                        }
//                    })
//            })
//        }
        
    }
    init() {
        
    }
    
    func likeRecipe() {
        _liked = true
    }
    
    func dislikeRecipe() {
        _liked = false
    }
    
    init(recipeKey: String, recipeData: Dictionary<String, AnyObject>) {
        
        self._recipeID = recipeKey
        
        if let title = recipeData["Title"] {
            self._title = title as! String
        }
        
        if let description = recipeData["Description"] {
            self._description = description as! String
        }
        
        if let likes = recipeData["Likes"] {
            self._likes = likes as! Int
        }
        
        if let pictureUrl = recipeData["PictureUrl"] {
            self._pictureUrl = pictureUrl as! String
            if _pictureUrl == oldDefaultImageURL {
                _pictureUrl = defaultImageURL
            }
        }
        
        if let procedure = recipeData["Procedure"] {
            self._procedure = procedure as! [String]
        }
        
        if let postedByUserName = recipeData["PostedByUserName"] {
            self._postedByUserName = postedByUserName as! String
            //print("USERNAME" + self._postedByUserName)
        }
        
        if let postedByUserKey = recipeData["PostedByUserKey"] {
            self._postedByUserKey = postedByUserKey as! String
        }
        
        let likesRef = DataService.ds.REF_USERS_CURRENT.child("likedRecipes").child(self.recipeID)
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self._liked = false
            }
            else {
                self._liked = true
            }
        })
        // Download Image
        /*
            let ref = FIRStorage.storage().reference(forURL: pictureUrl)
            ref.data(withMaxSize: 2*1024*1024, completion: { (data, error) in
                if(error != nil) {
                    print("Error downloading image")
                    if let img = RecipesViewController.imageCache.object(forKey: unableToDownloadImageURL as NSString) {
                        self.setImage(image: img)
                        //self.recipe.setImage(image: img)
                    }
                }
                    
                else {
//                    print("image downloaded successfully")
                    if let imageData = data {
                        if let displayImage = UIImage(data: imageData) {
                            self.setImage(image: displayImage)
                            RecipesViewController.imageCache.setObject(displayImage, forKey: self.pictureUrl as NSString)
                        }
                    }
                }
            })
         */
        if pictureUrl != defaultImageURL || pictureUrl != oldDefaultImageURL {
            let url = URL(string: pictureUrl)!
            
            ImageDownloader.default.downloadImage(with: url, options: [], progressBlock: nil) {
                (image, error, url, data) in
                if error != nil {
                    print("image couldn't be downloaded")
                }
                else {
                    if let displayImage = image {
                        print("Image downloaded successfully")
                        self.setImage(image: displayImage)
                        ImageCache.default.store(displayImage, forKey: self.pictureUrl)
                    }
                    else {
                        print("image couldn't be downloaded")
                    }
                }
            }
        }
        else {
            self.setImage(image: #imageLiteral(resourceName: "default"))
        }
    }
    
    func appendIngredients(ingredient: IngredientWithQuantity) {
        self._ingredients.append(ingredient)
    }
    
    func numberOfIngredientsNotAvailableInUsersFridge(usersFridge: [String]) -> Int {
        
        if(usersFridge.count == 0) {
            return Int(INT_MAX)
        }
        
        var capitalizedUsersFridge = [String]()
        for item in usersFridge {
            capitalizedUsersFridge.append(item.capitalized)
        }
        
        var _numberOfIngredientsNotAvailableInUsersFridge = 0
        
        
//        for ingredient in ingredients {
//            let capitalizedIngredient = ingredient.ingredient.capitalized
//            
//            if(!( (capitalizedUsersFridge.contains(capitalizedIngredient)) || (capitalizedUsersFridge.contains(capitalizedIngredient + "S")) || (usersFridge.contains(capitalizedIngredient + "ES")))){
//                
//                for item in capitalizedUsersFridge {
//                    if(item.contains(capitalizedIngredient) || capitalizedIngredient.contains(item)) {
//                        
//                    }
//                    else {
//                        if(!ingredient.isOptional) {
//                            print(ingredient.ingredient)
//                            print(ingredient.isOptional)
//                            _numberOfIngredientsNotAvailableInUsersFridge += 1
//                        }
//                    }
//                }
//            }
//        }
        
        
        for ingredient in ingredients {
            let capitalizedIngredient = ingredient.ingredient.capitalized
            var exists = false
            for item in capitalizedUsersFridge {
                if((item.contains(capitalizedIngredient) || capitalizedIngredient.contains(item)) && !exists) {
                    exists = true
                }
            }
            if (!exists) {
                if (!ingredient.isOptional) {
                    _numberOfIngredientsNotAvailableInUsersFridge += 1
                }
            }
        }
        return _numberOfIngredientsNotAvailableInUsersFridge
    }
    
    func setImage(image: UIImage) {
        self._recipeImage = image
    }
    
    func adjustLikes(addLike: Bool, completion: @escaping (Bool) -> ()){
        var likes = _likes!
        if(addLike == true) {
            likes = likes + 1
        }
        else {
            likes = likes - 1
        }
        print("LIKE BUTTON TAPPED")
        print("Likes: \(likes)")
        
        DataService.ds.REF_RECIPES.child(_recipeID).child("Likes").setValue(likes){
            (error, ref) -> Void in
            if (error != nil) {
                print("There Was a problem")
                completion(false)
                
            }
            else {
                print("Successfully liked")
                self._likes = likes
                completion(true)
            }
        }
    }
}

//(ingredient.ingredient.caseInsensitiveCompare(item) == ComparisonResult.orderedSame) || (plural.caseInsensitiveCompare(item) == ComparisonResult.orderedSame))
