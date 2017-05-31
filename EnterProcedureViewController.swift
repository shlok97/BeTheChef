//
//  EnterProcedureViewController.swift
//  BeTheChef
//
//  Created by Shlok Kapoor on 14/12/16.
//  Copyright © 2016 AppGali. All rights reserved.
//

import UIKit

class EnterProcedureViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,  UITextFieldDelegate  {
    
    var steps = [String]()
    
    @IBOutlet weak var procedureTextField: UITextField!
    @IBOutlet weak var addStepButton: AddButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    
    private var _ingredients = [IngredientWithQuantity]()
    private var _recipeTitle = ""
    private var _recipeDescription: String?
    private var _displayImage: UIImage?
    var reviewRecipeViewController: ReviewRecipeViewController?

    @IBAction func addStepButtonAction(_ sender: Any) {
        
        if(procedureTextField.text != "") {
            steps.append(procedureTextField.text!)
            procedureTextField.text = ""
            self.view.endEditing(true)
        }
        print(steps.count)
        addStepButton.setTitle("Add Step \(steps.count + 1)", for: .normal)
        tableView.reloadData()
        self.tableView.tableViewScrollToBottom(animated: true)
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        if(steps.count != 0) {
            if (_recipeDescription == nil) {
                _recipeDescription = ""
            }
            
//        let newRecipe = Recipe(title: _recipeTitle, likes: 0, description: _recipeDescription!, ingredients: _ingredients, pictureUrl: "", procedure: steps)
//        print(newRecipe.title)
//        print(newRecipe.description)
//        for ingredient in newRecipe.ingredients {
//        print(ingredient.ingredientWithQuantity)
//        }
//        print(newRecipe.procedure)
//        
        performSegue(withIdentifier: "doneSubmittingSegue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "doneSubmittingSegue" {
            reviewRecipeViewController = segue.destination as? ReviewRecipeViewController
            reviewRecipeViewController?.getRecipeDetails(recipeTitle: _recipeTitle, recipeDescription: _recipeDescription, recipeImage: _displayImage, procedure: steps, ingredients: _ingredients)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        self.procedureTextField.delegate = self
        self.hideKeyboardWhenTappedAround()
        
    }
    
    func updateRecipeInformation(recipeTitle: String, recipeDescription: String?, displayImage: UIImage?, ingredients: [IngredientWithQuantity]) {
        _recipeTitle = recipeTitle
        _recipeDescription = recipeDescription
        _displayImage = displayImage
        _ingredients = ingredients
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return steps.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let step = steps[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "procedureCell") as? ProcedureTableViewCell {
            cell.configCell(procedure: step)
            return cell
        }
        return ProcedureTableViewCell()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            steps.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
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
    
}
