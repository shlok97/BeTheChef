//
//  ReviewRecipeViewController.swift
//  BeTheChef
//
//  Created by Shlok Kapoor on 15/12/16.
//  Copyright © 2016 AppGali. All rights reserved.
//

import UIKit
import Firebase

class ReviewRecipeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var displayImage: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private var section = ["INGREDIENTS", "STEPS"]
    
    var ingredients = [IngredientWithQuantity]()
    var procedure = [String]()
    var recipeTitle = String()
    var recipeDescription: String?
    var recipeImage: UIImage?
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = recipeTitle
        if ((recipeDescription) != nil) {
            descriptionLabel.text = recipeDescription
        }
        else {
            descriptionLabel.text = ""
        }
        if (recipeImage != nil) {
            displayImage.image = recipeImage
        }
        tableView.reloadData()
    }
    
    func getRecipeDetails(recipeTitle: String, recipeDescription: String?, recipeImage: UIImage?, procedure: [String], ingredients: [IngredientWithQuantity]) {
        self.recipeTitle = recipeTitle
        self.recipeDescription = recipeDescription
        self.recipeImage = recipeImage
        self.procedure = procedure
        self.ingredients = ingredients
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return ingredients.count
        }
        else {
            return procedure.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ingredientCell", for: indexPath) as! IngredientTableViewCell
            cell.configCell(ingredient: ingredients[indexPath.row].ingredientWithQuantity)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "procedureCell", for: indexPath) as! ProcedureTableViewCell
            cell.configCell(procedure: procedure[indexPath.row])
            return cell
        }
        
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.section[section]
    }
    
    //Set size of the tableview cell
    func tableView(_ tableView: UITableView, heightForRowAt: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    @IBAction func submitButton(_ sender: Any) {
        postIngredientsToFirebase()
        processImage()
        performSegue(withIdentifier: "confirmSubmissionSegue", sender: nil)
    }
    
    func postIngredientsToFirebase() {
        for ingredient in ingredients {
            DataService.ds.REF_BASE.child("Ingredients").child(ingredient.ingredient).setValue(true)
        }
    }
    
    func processImage() {
        
        DispatchQueue.global(qos: .background).async {
            var downloadURL = String()
            if (self.recipeImage != nil) {
                
                if let image = UIImageJPEGRepresentation(self.recipeImage!, 0.01) {
                    let imageUid = NSUUID().uuidString
                    let metadata = FIRStorageMetadata()
                    metadata.contentType = "image/jpeg"
                    DataService.ds.REF_RECIPES_IMAGES.child(imageUid).put(image, metadata: metadata, completion: { (metadata, error) in
                        if(error != nil) {
                            print("IMAGE WAS NOT UPLOADED")
                        }
                        else {
                            print("IMAGE SUCCESSFULLY UPLOADED")
                            let downloadURL = metadata?.downloadURL()?.absoluteString
                            print(downloadURL!)
                            self.postToFirebase(pictureUrl: downloadURL!)
                        }
                    })
                }
            }
            else {
                downloadURL = defaultImageURL
                self.postToFirebase(pictureUrl: downloadURL)
            }
        }
        
    }
    
    func postToFirebase(pictureUrl: String) {
        
        let post: Dictionary<String, AnyObject> = [
            "Title": recipeTitle as AnyObject,
            "Description": recipeDescription as AnyObject,
            "Likes": 0 as AnyObject,
            "Procedure": procedure as AnyObject,
            "PictureUrl": pictureUrl as AnyObject,
            "PostedByUserKey": FIRAuth.auth()?.currentUser?.uid as AnyObject,
            "PostedByUserName": FIRAuth.auth()?.currentUser?.displayName as AnyObject,
            "Approved": 0 as AnyObject
        ]
        
        let key = DataService.ds.REF_RECIPES.childByAutoId().key
        DataService.ds.REF_RECIPES.child(key).setValue(post)
        
        for ingredient in ingredients {
            var ingredientWithQuantity = Dictionary<String,String>()
            if(ingredient.isOptional) {
                ingredientWithQuantity = [
                    "Quantity": ingredient.quantity,
                    "Ingredient": ingredient.ingredient,
                    "isOptional": "true"
            ]
            }
            else {
                ingredientWithQuantity = [
                    "Quantity": ingredient.quantity,
                    "Ingredient": ingredient.ingredient,
                    "isOptional": "false"
                ]
            }
            
            DataService.ds.REF_RECIPES.child(key).child("ingredients").childByAutoId().setValue(ingredientWithQuantity)
            DataService.ds.REF_BASE.child("Categories").child(recipeDescription!).child(key).setValue(true)
        }
        //Posting the recipe keys posted by a user in the database
        
//        let recipeData: Dictionary<String, String> = [
//            "Id": key,
//            "Name": recipeTitle
//        ]
        DataService.ds.REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).child("recipesPosted").child(key).setValue("true")
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

