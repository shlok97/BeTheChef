//
//  DisplayRecipeViewController.swift
//  BeTheChef
//
//  Created by Shlok Kapoor on 17/12/16.
//  Copyright © 2016 AppGali. All rights reserved.
//

import UIKit
import Firebase

class DisplayRecipeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var displayImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var postedByUserLabel: UILabel!
    private var section = ["INGREDIENTS", "STEPS"]
    var postedByUserText = String()
    weak var recipesViewController: RecipesViewController?
    weak var myProfileViewController: MyProfileViewController?
    
    var ingredients = [IngredientWithQuantity]()
    var procedure = [String]()
    var recipeTitle = String()
    var recipeDescription: String?
    var recipeImage: UIImage?
    var imageURL = String()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidAppear(_ animated: Bool) {
        print("View appeared")
        if let img = RecipesViewController.imageCache.object(forKey: self.imageURL as NSString) {
            self.recipeImage = img
            
            if let image = recipeImage {
                //self.recipeImage = image
                displayImage.image = image
            }
            /*
            else {
                let ref = FIRStorage.storage().reference(forURL: imageURL)
                ref.data(withMaxSize: 2*1024*1024, completion: { (data, error) in
                    if(error != nil) {
                        print("Error downloading image")
                    }
                    else {
                        print("SHOW image downloaded successfully")
                        if let imageData = data {
                            if let image = UIImage(data: imageData) {
                                //self.recipeImage = image
                                self.displayImage.image = image
                                RecipesViewController.imageCache.setObject(image, forKey: self.imageURL as NSString)
                            }
                        }
                    }
                })
            }
            */
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.titleLabel.sizeToFit()
        self.descriptionLabel.adjustsFontSizeToFitWidth = true
        delay(bySeconds: 0.1) {
            self.loadData()
        }
        
    }
    
    func loadData() {
        titleLabel.text = recipeTitle
        displayImage.image = recipeImage
        postedByUserLabel.text = postedByUserText
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped(_:)))
        edgePan.edges = .left
        self.view.addGestureRecognizer(edgePan)
        if ((recipeDescription) != nil) {
            descriptionLabel.text = recipeDescription
        }
        else {
            descriptionLabel.text = ""
        }
        displayImage.image = recipeImage
        tableView.reloadData()
    }
    
    
    
    func getRecipeDetails(recipeTitle: String, recipeDescription: String?, procedure: [String], ingredients: [IngredientWithQuantity], postedByUser: String?, imageUrl: String, img: UIImage? = nil) {
//        print(recipeTitle)
        
        self.recipeTitle = recipeTitle
        self.recipeDescription = recipeDescription
        self.recipeImage = img
        self.postedByUserText = "Posted by " + postedByUser!
        self.imageURL = imageUrl
        
        for step in procedure {
            self.procedure.append(step)
        }
        
        self.ingredients = ingredients
        
        if img == nil {
            let url = URL(string: imageUrl)
            displayImage.kf.indicatorType = .activity
            displayImage.kf.setImage(with: url, completionHandler: {
                (image, error, cacheType, imageUrl) in
                if error != nil {
                    self.displayImage.image = UIImage(named: "unabletodownload")
                }
            })
        }
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
    
    func tableView(_ tableView: UITableView, heightForRowAt: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
//    override func previewActionItems() -> [UIPreviewActionItem] {
//        let shareAction = UIPreviewAction(title: "Share", style: .default) {
//            (previewAction, viewController) in
//            
//            if let recipesTVC = self.recipesViewController, activityVC = self. {
//                
//            }
//        }
//    }
//    private var activityViewController: UIActivityViewController? {
//        guard let
//    }
    
}

