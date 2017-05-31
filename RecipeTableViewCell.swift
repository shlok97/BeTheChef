//
//  RecipeTableViewCell.swift
//  BeTheChef
//
//  Created by Shlok Kapoor on 14/12/16.
//  Copyright © 2016 AppGali. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class RecipeTableViewCell: UITableViewCell {
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var likeButton: FavouriteButtonView!
    
    var recipe: Recipe!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var likesRef = FIRDatabaseReference()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeButtonTapped))
        tap.numberOfTapsRequired = 1
        likeButton.addGestureRecognizer(tap)
        
        self.activityIndicator.startAnimating()
        titleLabel.sizeToFit()
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.foodImage.image = UIImage()
    }
    
    public func disableLikeButton() {
        self.isUserInteractionEnabled = true
        Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(enableLikeButton), userInfo: nil, repeats: false)
    }
    
    func enableLikeButton() {
        self.isUserInteractionEnabled = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func likeButtonTapped() {
        print("TAP")
        recipeLikedOrNot = true
        
        self.likesRef = DataService.ds.REF_USERS_CURRENT.child("likedRecipes").child(self.recipe.recipeID)
        if (!recipe.liked) {
            debugPrint("tapped on", recipe)
                self.likeButton.imageView?.image = UIImage(named: "starSolid")
                self.recipe.adjustLikes(addLike: true, completion: { (success) in
                    if(success) {
                        DispatchQueue.global(qos: .background).async {
                            print("Successfully Liked")
                            self.likesRef.setValue(true)
                            self.recipe.likeRecipe()
                        }
                        
                    }
                    else {
                        self.likeButton.imageView?.image = UIImage(named: "star")
                    }
                })
            }
            else {
            
                self.likeButton.imageView?.image = UIImage(named: "star")
                self.recipe.adjustLikes(addLike: false, completion: { (success) in
                    if(success) {
                        DispatchQueue.global(qos: .background).async {
                            print("Successfully disiked")
                            self.recipe.dislikeRecipe()
                            self.likesRef.removeValue()
                        }
                    }
                    else {
                        self.likeButton.imageView?.image = UIImage(named: "starSolid")
                    }
                })
            }
    }
    
    @IBAction func likeButtonTppd(_ sender: Any) {
    }

    func configCell(recipe: Recipe, img: UIImage? = nil) {
        titleLabel.numberOfLines = 3
//        var img = img
        print("Cell Configured")
        self.recipe = recipe
//        likesRef = DataService.ds.REF_USERS_CURRENT.child("likedRecipes").child(self.recipe.recipeID)
        titleLabel.text = recipe.title
//        descriptionLabel.text = recipe.description
        self.activityIndicator.startAnimating()
//        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
//            if let _ = snapshot.value as? NSNull {
//                self.likeButton.imageView?.image = UIImage(named: "star")
//            }
//            else {
//                self.likeButton.imageView?.image = UIImage(named: "starSolid")
//            }
//        })
//        
//        if (img == nil) {
//            img = recipe.recipeImage
//        }
        
        if(recipe.liked) {
            self.likeButton.imageView?.image = UIImage(named: "starSolid")
        }
            
        else {
            self.likeButton.imageView?.image = UIImage(named: "star")
        }
        
        if(recipe.pictureUrl == defaultImageURL) {
            //self.foodImage.image = img
            //self.recipe.setImage(image: img!)
            //self.removeActivityIndicator()
            self.foodImage.image = #imageLiteral(resourceName: "default")
            self.removeActivityIndicator()
        }
        else {
            // Image not Default
            ImageCache.default.retrieveImage(forKey: recipe.pictureUrl, options: nil) {
                image, cacheType in
                if let image = image {
                    self.foodImage.image = image
                    self.removeActivityIndicator()
                }
                else {
                    let url = URL(string: recipe.pictureUrl)!
                    ImageDownloader.default.downloadImage(with: url, options: [], progressBlock: nil) {
                        (image, error, url, data) in
                        if error != nil {
                            print("image couldn't be downloaded")
                            self.foodImage.image = UIImage(named: "unabletodownload")
                            self.removeActivityIndicator()
                        }
                        else {
                            if let displayImage = image {
                                print("Image downloaded successfully")
                                recipe.setImage(image: displayImage)
                                ImageCache.default.store(displayImage, forKey: recipe.pictureUrl)
                                self.foodImage.image = displayImage
                                self.removeActivityIndicator()
                            }
                            else {
                                print("image couldn't be downloaded")
                                self.foodImage.image = UIImage(named: "unabletodownload")
                                self.removeActivityIndicator()
                            }
                        }
                    }
                }
            }
            
            
            /*
            if let displayImage = RecipesViewController.imageCache.object(forKey: recipe.pictureUrl as NSString) {
                self.foodImage.image = displayImage
                self.removeActivityIndicator()
            }
            else {
                let ref = FIRStorage.storage().reference(forURL: recipe.pictureUrl)
                ref.data(withMaxSize: 2*1024*1024, completion: { (data, error) in
                    if(error != nil) {
                        print("Error downloading image")
                        if let img = RecipesViewController.imageCache.object(forKey: unableToDownloadImageURL as NSString) {
                            self.removeActivityIndicator()
                            //change
                            self.foodImage.image = img
                            //self.recipe.setImage(image: img)
                        }
                    }
                        
                    else {
                        //                    print("image downloaded successfully")
                        if let imageData = data {
                            if let image = UIImage(data: imageData) {
                                self.foodImage.image = image
                                //self.recipe.setImage(image: image)
                                self.removeActivityIndicator()
                                RecipesViewController.imageCache.setObject(image, forKey: recipe.pictureUrl as NSString)
                            }
                        }
                        else {
                            print("IMAGE NOT FOUND")
                            if let img = RecipesViewController.imageCache.object(forKey: unableToDownloadImageURL as NSString) {
                                self.removeActivityIndicator()
                                //change
                                self.foodImage.image = img
                                //self.recipe.setImage(image: img)
                            }
                        }
                    }
                })
            }
            */
        }
    }
    
    func removeActivityIndicator() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.alpha = 0
    }
}

extension UIImage {
    func resizeImage(newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(newWidth, newHeight))
        self.draw(in: CGRect(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    func resizeImage(scale: CGFloat) -> UIImage {
        
        let newWidth = scale * self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(newWidth, newHeight))
        self.draw(in: CGRect(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
extension CGRect{
    init(_ x:CGFloat,_ y:CGFloat,_ width:CGFloat,_ height:CGFloat) {
        self.init(x:x,y:y,width:width,height:height)
    }
    
}
extension CGSize{
    init(_ width:CGFloat,_ height:CGFloat) {
        self.init(width:width,height:height)
    }
}
extension CGPoint{
    init(_ x:CGFloat,_ y:CGFloat) {
        self.init(x:x,y:y)
    }
}
