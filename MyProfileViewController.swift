//
//  MyProfileViewController.swift
//  BeTheChef
//
//  Created by Shlok Kapoor on 19/12/16.
//  Copyright © 2016 AppGali. All rights reserved.
//


import UIKit
import Firebase
import SwiftKeychainWrapper
import ObjectiveC
import FBSDKCoreKit
import FBSDKLoginKit
import Kingfisher

class MyProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var selectedRow = 0
    var showRecipeViewController: DisplayRecipeViewController?
    let userID = FIRAuth.auth()?.currentUser?.uid
    let userName = FIRAuth.auth()?.currentUser?.displayName
    var currentUser = User()
    var spinner = UIActivityIndicatorView()
    var recipesPostedByUser = [Recipe]()
    var recipesLikedByUser = [Recipe]()
    var loaded = false
    var loadTimer = Timer()
    var refreshControl = UIRefreshControl()
    
    var numberOfTimesTableWasLoaded = 0
    
    @IBOutlet weak var postedOrLikedSegmentedControl: UISegmentedControl!
    
    @IBAction func postedOrLikedSegmentedControlValueChanged(_ sender: Any) {
        resetTable()
        loadTimer.invalidate()
        numberOfTimesTableWasLoaded = 0
        //viewWillAppear(true)
        
        
        self.loaded = false
        self.loadTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                              target: self,
                                              selector: #selector(self.loadTable),
                                              userInfo: nil,
                                              repeats: true)
        /*
        if postedOrLikedSegmentedControl.selectedSegmentIndex == 1 {
            self.currentUser.loadRecipesLikedByUser() {
                success in
                guard success == true
                    else {
                        return
                }
                
                print("Loaded Recipes Posted")
                self.loadTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                      target: self,
                                                      selector: #selector(self.loadTable),
                                                      userInfo: nil,
                                                      repeats: true)
                
            }
        }
        */
        
    }
    
    
    override func viewDidLoad() {
        currentUser = User()
        super.viewDidLoad()
        self.tableView.setLoadingScreen(spinner: &self.spinner)
        currentUser = User(userKey: userID!, userName: userName!)
        displayName.text = userName
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self as UIViewControllerPreviewingDelegate, sourceView: tableView)
        }
        self.resetTable()
        
        self.currentUser.loadRecipesLikedByUser() {
            success in
            guard success == true
                else {
                    return
            }
            //Successfully Downloaded recipes posted by user
            self.currentUser.loadRecipesPostedByUser() {
                success in
                
                guard success == true
                    else {
                        return
                }
                //Successfully Downloaded recipes liked by user
                
                self.resetTable()
                self.loaded = true
                self.loadTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                      target: self,
                                                      selector: #selector(self.loadTable),
                                                      userInfo: nil,
                                                      repeats: true)
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loaded = false
        
        numberOfTimesTableWasLoaded = 0
        //loaded = false
        
        /*
        self.currentUser.loadRecipesPostedByUser() {
            success in
            guard success == true
                else {
                    return
            }
            print("postedLoaded")
            self.loaded = true
            self.loadTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                 target: self,
                                                 selector: #selector(self.loadTable),
                                                 userInfo: nil,
                                                 repeats: true)
        }
        
        resetTable()
        */
        
        print("LoadTimerStarted")

        if recipeLikedOrNot {
            viewDidLoad()
        }
        recipeLikedOrNot = false
        /*
        loadTimer = Timer.scheduledTimer(timeInterval: 0.2,
                                         target: self,
                                         selector: #selector(self.loadTable),
                                         userInfo: nil,
                                         repeats: true)
 */
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refreshTable), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
    }
    func refreshTable() {
        viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        tableView.reloadData()
        loadTimer.invalidate()
        refreshControl.removeFromSuperview()
    }
    
    func resetTable() {
        self.recipesLikedByUser.removeAll()
        self.recipesPostedByUser.removeAll()
        self.tableView.reloadData()
    }
    
//    func load(withDelay :Double) {
//        delay(bySeconds: withDelay) {
//            self.loadTable()
//        }
//    }

    func loadTable () {
        if(loaded) {
            self.recipesLikedByUser = self.currentUser.recipesLikedByUser
            self.recipesPostedByUser = self.currentUser.recipesPostedByUser
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
            self.tableView.removeLoadingScreen(spinner: &self.spinner)
            numberOfTimesTableWasLoaded += 1
            if(numberOfTimesTableWasLoaded >= 40) {
                loadTimer.invalidate()
                print("TimerInvalidated")
                loaded = false
            }
        }
    }
    
    @IBAction func likeButtonTapped(_ sender: Any) {
        postedOrLikedSegmentedControlValueChanged(self)
    }
    
    @IBAction func logOut(_ sender: Any) {
        let keychainWrapper = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("User removed \(keychainWrapper)")
        FBSDKAccessToken.current()
        
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "signOutSegue", sender: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(postedOrLikedSegmentedControl.selectedSegmentIndex == 0) {
            return self.currentUser.recipesPostedByUser.count
        }
        else {
            return self.currentUser.recipesLikedByUser.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var recipe = Recipe()
        
        if(postedOrLikedSegmentedControl.selectedSegmentIndex == 0) {
            recipe = self.currentUser.recipesPostedByUser[indexPath.row]
        }
        else {
            recipe = self.currentUser.recipesLikedByUser[indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell", for: indexPath) as! RecipeTableViewCell
        cell.disableLikeButton()
        if let img = RecipesViewController.imageCache.object(forKey: recipe.pictureUrl as NSString) {
            cell.configCell(recipe: recipe, img: img)
            return cell
        }
        else {
            cell.configCell(recipe: recipe, img: recipe.recipeImage)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedRow = indexPath.row
        print(selectedRow)
        performSegue(withIdentifier: "showRecipeSegue", sender: nil)
    }
    
    //Deleting Recipe
    
    //Show recipe details
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRecipeSegue" {
            var selectedRecipe = Recipe()
            if(postedOrLikedSegmentedControl.selectedSegmentIndex == 0) {
                selectedRecipe = self.currentUser.recipesPostedByUser[selectedRow]
            }
            else {
                selectedRecipe = self.currentUser.recipesLikedByUser[selectedRow]
            }
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
        }
    }
}

extension MyProfileViewController: UIViewControllerPreviewingDelegate {
    
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
        
        ImageCache.default.retrieveImage(forKey: selectedRecipe.pictureUrl, options: nil) {
            image, cacheType in
            if let img = image {
                recipeVC.getRecipeDetails(recipeTitle: selectedRecipe.title, recipeDescription: selectedRecipe.description, procedure: selectedRecipe.procedure, ingredients: selectedRecipe.ingredients, postedByUser: selectedRecipe.postedByUserName, imageUrl: selectedRecipe.pictureUrl, img: img)
            }
            else {
                recipeVC.getRecipeDetails(recipeTitle: selectedRecipe.title, recipeDescription: selectedRecipe.description, procedure: selectedRecipe.procedure, ingredients: selectedRecipe.ingredients, postedByUser: selectedRecipe.postedByUserName, imageUrl: selectedRecipe.pictureUrl)
            }
        }
        /*
        recipeVC.getRecipeDetails(recipeTitle: (selectedRecipe?.title)!, recipeDescription: selectedRecipe?.description, procedure: (selectedRecipe?.procedure)!, ingredients: (selectedRecipe?.ingredients)!, postedByUser: selectedRecipe?.postedByUserName, imageUrl: (selectedRecipe?.pictureUrl)!, img: selectedRecipe?.recipeImage)
        */
        previewingContext.sourceRect = cell.frame
        return recipeVC
    }
    
    //pop
    @available(iOS 9.0, *)
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.show(viewControllerToCommit, sender: self)
    }
}

extension UIViewController {
    
    public func delay(bySeconds seconds: Double, dispatchLevel: DispatchLevel = .main, closure: @escaping () -> Void) {
        let dispatchTime = DispatchTime.now() + seconds
        dispatchLevel.dispatchQueue.asyncAfter(deadline: dispatchTime, execute: closure)
    }
    
    public enum DispatchLevel {
        case main, userInteractive, userInitiated, utility, background
        var dispatchQueue: DispatchQueue {
            switch self {
            case .main:                 return DispatchQueue.main
            case .userInteractive:      return DispatchQueue.global(qos: .userInteractive)
            case .userInitiated:        return DispatchQueue.global(qos: .userInitiated)
            case .utility:              return DispatchQueue.global(qos: .utility)
            case .background:           return DispatchQueue.global(qos: .background)
            }
        }
    }
    
}
