//
//  RecipesViewController.swift
//  BeTheChef
//
//  Created by Shlok Kapoor on 14/12/16.
//  Copyright © 2016 AppGali. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import Kingfisher

var recipeLikedOrNot = false

class RecipesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    private var currentUser = User()
    private var showRecipeViewController: DisplayRecipeViewController?
    private var selectedRow = 0
    private var selectedSection = 0
    var spinner = UIActivityIndicatorView()
    var loaded = false
    private var section = ["ACCORDING TO YOUR FRIDGE", "OTHER RECOMMENDATIONS"]
    var loadTimer = Timer()
    var numberOfTimesTableWasLoaded = 0
    let userID = FIRAuth.auth()?.currentUser?.uid
    var tableFinishedLoading = false
    var suggestedRecipes = [Recipe]()
    var otherSuggestions = [Recipe]()
    var refreshControl: UIRefreshControl!
    
//    var userInteractionStarted = false
//    A recipe is liked
    @IBAction func recipeLiked(_ sender: Any) {
        print("Like Button Tapped")
    }
    
    func initialise() {
        suggestedRecipes.removeAll()
        otherSuggestions.removeAll()
        
        suggestedRecipes = currentUser.recommendedRecipes
        otherSuggestions = currentUser.otherRecommendations
    }
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    override func viewDidAppear(_ animated: Bool) {
        recipeLikedOrNot = false
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refreshTable), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self as UIViewControllerPreviewingDelegate, sourceView: tableView)
        }
        currentUser = User()
        initialise()
        tableFinishedLoading = false
        self.refreshData()
        tableView.setLoadingScreen(spinner: &spinner)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        currentUser = User()
//        initialise()
//        tableFinishedLoading = false
//        self.refreshData()
//        tableView.setLoadingScreen(spinner: &spinner)
        
        
        if fridgeChanged {
            refreshTable()
            fridgeChanged = false
        }
    }
    
    func refreshTable() {
        currentUser = User()
        tableView.reloadData()
        viewDidLoad()
    }
    
    func reloadTable() {
        tableView.reloadData()
    }
    
    func refreshData() {
        loaded = false
        numberOfTimesTableWasLoaded = 0
        currentUser.loadRecipes {
            success in
            guard success == true
            else {
                return
            }
            print("Successfully downloaded recipes")
            self.loaded = true
            self.loadTable()
            self.loadTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                             target: self,
                                             selector: #selector(self.loadTable),
                                             userInfo: nil,
                                             repeats: true)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        loadTimer.invalidate()
//        currentUser = User()
//        initialise()
        refreshControl.removeFromSuperview()
    }
    
    func loadTable() {
        
        if(loaded) {
            self.tableView.removeLoadingScreen(spinner: &self.spinner)
            self.refreshControl.endRefreshing()
            self.reloadTable()
            numberOfTimesTableWasLoaded += 1
            initialise()
            if(numberOfTimesTableWasLoaded >= 40) {
                //changes made here
                loadTimer.invalidate()
                loaded = false
                self.tableFinishedLoading = true
                Timer.scheduledTimer(timeInterval: 2,
                                     target: self,
                                     selector: #selector(self.reloadTable),
                                     userInfo: nil,
                                     repeats: true)
//                self.tableView.isUserInteractionEnabled = true
                
            }
        }
    }
    
    
// MARK: Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return currentUser.recommendedRecipes.count
        }
        else {
            return currentUser.otherRecommendations.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Reload")
        if (indexPath.section == 0) {
            let recipe = currentUser.recommendedRecipes[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell", for: indexPath) as! RecipeTableViewCell
            
            if let img = RecipesViewController.imageCache.object(forKey: recipe.pictureUrl as NSString) {
                cell.configCell(recipe: recipe, img: img)
                return cell
            }
            else {
                cell.configCell(recipe: recipe, img: recipe.recipeImage)
                return cell
            }
        }
        else {
            let recipe = currentUser.otherRecommendations[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell", for: indexPath) as! RecipeTableViewCell
            
            if let img = RecipesViewController.imageCache.object(forKey: recipe.pictureUrl as NSString) {
                cell.configCell(recipe: recipe, img: img)
                return cell
            }
            else {
                cell.configCell(recipe: recipe, img: recipe.recipeImage)
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        selectedSection = indexPath.section
        performSegue(withIdentifier: "showRecipeSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.section[section]
    }
    //Set size of tableview cell
    func tableView(_ tableView: UITableView, heightForRowAt: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showRecipeSegue" {
            
            if selectedSection == 0 {
                
                let selectedRecipe = currentUser.recommendedRecipes[selectedRow]
                
                showRecipeViewController = segue.destination as? DisplayRecipeViewController

              //if let img = RecipesViewController.imageCache.object(forKey: selectedRecipe.pictureUrl as NSString) {
                
                
                ImageCache.default.retrieveImage(forKey: selectedRecipe.pictureUrl, options: nil) {
                    image, cacheType in
                    if let img = image {
                        self.showRecipeViewController?.getRecipeDetails(recipeTitle: selectedRecipe.title, recipeDescription: selectedRecipe.description, procedure: selectedRecipe.procedure, ingredients: selectedRecipe.ingredients, postedByUser: selectedRecipe.postedByUserName, imageUrl: selectedRecipe.pictureUrl, img: img)
                    }
                    else {
                        self.showRecipeViewController?.getRecipeDetails(recipeTitle: selectedRecipe.title, recipeDescription: selectedRecipe.description, procedure: selectedRecipe.procedure, ingredients: selectedRecipe.ingredients, postedByUser: selectedRecipe.postedByUserName, imageUrl: selectedRecipe.pictureUrl)
                    }
                }
                
                /*
                if let img = RecipesViewController.imageCache.object(forKey: selectedRecipe.pictureUrl as NSString) {
                    
                    showRecipeViewController?.getRecipeDetails(recipeTitle: selectedRecipe.title, recipeDescription: selectedRecipe.description, procedure: selectedRecipe.procedure, ingredients: selectedRecipe.ingredients, postedByUser: selectedRecipe.postedByUserName, imageUrl: selectedRecipe.pictureUrl, img: img)
                }
                else {
                    showRecipeViewController?.getRecipeDetails(recipeTitle: selectedRecipe.title, recipeDescription: selectedRecipe.description, procedure: selectedRecipe.procedure, ingredients: selectedRecipe.ingredients, postedByUser: selectedRecipe.postedByUserName, imageUrl: selectedRecipe.pictureUrl)
                }
                */
            }
            else {
                let selectedRecipe = currentUser.otherRecommendations[selectedRow]
                showRecipeViewController = segue.destination as? DisplayRecipeViewController
                
                ImageCache.default.retrieveImage(forKey: selectedRecipe.pictureUrl, options: nil) {
                    image, cacheType in
                    if let img = image {
                        self.showRecipeViewController?.getRecipeDetails(recipeTitle: selectedRecipe.title, recipeDescription: selectedRecipe.description, procedure: selectedRecipe.procedure, ingredients: selectedRecipe.ingredients, postedByUser: selectedRecipe.postedByUserName, imageUrl: selectedRecipe.pictureUrl, img: img)
                    }
                    else {
                        self.showRecipeViewController?.getRecipeDetails(recipeTitle: selectedRecipe.title, recipeDescription: selectedRecipe.description, procedure: selectedRecipe.procedure, ingredients: selectedRecipe.ingredients, postedByUser: selectedRecipe.postedByUserName, imageUrl: selectedRecipe.pictureUrl)
                    }
                }
                
                
                /*
                if let img = RecipesViewController.imageCache.object(forKey: selectedRecipe.pictureUrl as NSString) {
                    showRecipeViewController?.getRecipeDetails(recipeTitle: selectedRecipe.title, recipeDescription: selectedRecipe.description, procedure: selectedRecipe.procedure, ingredients: selectedRecipe.ingredients, postedByUser: selectedRecipe.postedByUserName, imageUrl: selectedRecipe.pictureUrl, img: img)
                }
                else {
                    showRecipeViewController?.getRecipeDetails(recipeTitle: selectedRecipe.title, recipeDescription: selectedRecipe.description, procedure: selectedRecipe.procedure, ingredients: selectedRecipe.ingredients, postedByUser: selectedRecipe.postedByUserName, imageUrl: selectedRecipe.pictureUrl)
                }
                 */
            }
        }
    }
}

extension RecipesViewController: UIViewControllerPreviewingDelegate {
    
    //peek
    @available(iOS 9.0, *)
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location), let cell = tableView.cellForRow(at: indexPath) as? RecipeTableViewCell else {
            return nil
        }
        let identifier = "DisplayRecipeViewController"
        guard let recipeVC = storyboard?.instantiateViewController(withIdentifier: identifier) as? DisplayRecipeViewController else {
            return nil
        }
        let selectedRecipe = cell.recipe!
        
        /*
        if let img = RecipesViewController.imageCache.object(forKey: NSString(string: (selectedRecipe?.pictureUrl)!)) {
            recipeVC = getRecipeDetails(selectedRecipe: selectedRecipe!, img: img)
        }
            
        else {
            let ref = FIRStorage.storage().reference(forURL: (selectedRecipe?.pictureUrl)!)
            ref.data(withMaxSize: 2*1024*1024, completion: { (data, error) in
                if(error != nil) {
                    print("Error downloading image in recipe")
                    if let img = RecipesViewController.imageCache.object(forKey: unableToDownloadImageURL as NSString) {
                        recipeVC = self.getRecipeDetails(selectedRecipe: selectedRecipe!, img: img)
                    }
                }
                    
                else {
                    print("image downloaded successfully in recipe")
                    if let imageData = data {
                        if let image = UIImage(data: imageData) {
                            recipeVC = self.getRecipeDetails(selectedRecipe: selectedRecipe!, img: image)
                            RecipesViewController.imageCache.setObject(image, forKey: NSString(string: (selectedRecipe?.pictureUrl)!))
                        }
                    }
                }
            })
        }
        */
        
        ImageCache.default.retrieveImage(forKey: selectedRecipe.pictureUrl, options: nil) {
            image, cacheType in
            if let img = image {
                recipeVC.getRecipeDetails(recipeTitle: selectedRecipe.title, recipeDescription: selectedRecipe.description, procedure: selectedRecipe.procedure, ingredients: selectedRecipe.ingredients, postedByUser: selectedRecipe.postedByUserName, imageUrl: selectedRecipe.pictureUrl, img: img)
            }
            else {
                recipeVC.getRecipeDetails(recipeTitle: selectedRecipe.title, recipeDescription: selectedRecipe.description, procedure: selectedRecipe.procedure, ingredients: selectedRecipe.ingredients, postedByUser: selectedRecipe.postedByUserName, imageUrl: selectedRecipe.pictureUrl)
            }
        }
        
//        recipeVC.getRecipeDetails(recipeTitle: (selectedRecipe?.title)!, recipeDescription: selectedRecipe?.description, procedure: (selectedRecipe?.procedure)!, ingredients: (selectedRecipe?.ingredients)!, postedByUser: selectedRecipe?.postedByUserName, imageUrl: (selectedRecipe?.pictureUrl)!)
        
        previewingContext.sourceRect = cell.frame
        return recipeVC
    }
    
    //pop
    @available(iOS 9.0, *)
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.show(viewControllerToCommit, sender: self)
    }
    
    func getRecipeDetails(selectedRecipe: Recipe, img: UIImage) -> DisplayRecipeViewController {
        let recipeVC = DisplayRecipeViewController()
        
        recipeVC.getRecipeDetails(recipeTitle: (selectedRecipe.title), recipeDescription: selectedRecipe.description, procedure: (selectedRecipe.procedure), ingredients: (selectedRecipe.ingredients), postedByUser: selectedRecipe.postedByUserName, imageUrl: (selectedRecipe.pictureUrl), img: img)
        return recipeVC
    }
}


extension UITableView {
    /// Spinner shown during load the TableView
    
    //MARK: Activty Indicator
    func setLoadingScreen( spinner: inout UIActivityIndicatorView) {
        // Sets the view which contains the loading text and the spinner
        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (self.frame.width / 2) - (width / 2)
        let y = (self.frame.height / 2) - (height / 2)
        
        // Sets spinner
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        spinner.frame = CGRect(x: x,y: y,width: width,height: height)
        spinner.startAnimating()
        self.addSubview(spinner)
    }
    
    // Remove the activity indicator from the main view
    func removeLoadingScreen(spinner: inout UIActivityIndicatorView) {
        // Hides and stops the text and the spinner
        spinner.stopAnimating()
        spinner.isHidden = true
    }
}


