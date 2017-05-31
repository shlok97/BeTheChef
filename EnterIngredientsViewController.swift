//
//  EnterIngredientsViewController.swift
//  BeTheChef
//
//  Created by Shlok Kapoor on 14/12/16.
//  Copyright © 2016 AppGali. All rights reserved.
//

import UIKit
import Firebase

class EnterIngredientsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,  UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    var ingredients = [IngredientWithQuantity]()
    private var _recipeTitle = ""
    private var _recipeDescription: String?
    private var _displayImage: UIImage?
    @IBOutlet weak var quantityPicker: CategoryPickerView!
    var quantityPickerData = [[String](), [String]()]
    var quantity = String()
    var value = String()
    var unit = String()
    var isOptional = false
    var tap = UITapGestureRecognizer()
    
    
//    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var ingredientsTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var enterProcedureViewController: EnterProcedureViewController?
    
    
    //Auto Complete
    var autoCompletePossibilities = ["ABC", "DEF", "hello", "bye"]
    var autoComplete = [String]()
    @IBOutlet weak var autoCompleteTableView: UITableView!
    
    func updateTitleAndDescription(recipeTitle: String, recipeDescription: String?, displayImage: UIImage?) {
        _recipeTitle = recipeTitle
        _recipeDescription = recipeDescription
        _displayImage = displayImage
    }
    
    func setQuantityPickerData() {
        quantityPickerData = [["Some", "To Taste", "0.25", "0.5", "0.75", "1", "1.25", "1.5", "1.75", "2", "2.5", "3", "3.5", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "20", "25", "30", "50", "60", "75", "100", "150", "200" , "250", "300", "500", "600", "750"], ["","slices", "pieces", "teaspoons", "tablespoons", "cups", "glasses", "bottles", "ounces", "grams", "kilograms", "cloves"], ["required" ,"optional"]]
        quantity = "Some"
    }
    
    func setQuantityPickerDataToSingular() {
        var index = 0
        for _ in quantityPickerData[1] {
            quantityPickerData[1][index] = quantityPickerData[1][index].replacingOccurrences(of: "s", with: "", options: .literal, range: nil)
            if (quantityPickerData[1][index] == "teapoon") {
                quantityPickerData[1][index] = "teaspoon"
            }
            if (quantityPickerData[1][index] == "glae") {
                quantityPickerData[1][index] = "glass"
            }
            if (quantityPickerData[1][index] == "lice") {
                quantityPickerData[1][index] = "slice"
            }
            index += 1
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        self.ingredientsTextField.delegate = self
        print(_recipeTitle)
        self.quantityPicker.delegate = self
        self.quantityPicker.dataSource = self
        setQuantityPickerData()
        quantityPicker.reloadAllComponents()
        
        autoCompleteTableView.delegate = self
        autoCompleteTableView.dataSource = self
        
        getIngredientsFromFirebase()
        
//        var tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardSelector))
//        tap.numberOfTapsRequired = 1
//        self.tableView.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        autoCompleteTableView.isHidden = true
        
    }
    
    func getIngredientsFromFirebase() {
        DataService.ds.REF_BASE.child("Ingredients").observe(.value, with: {(snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                self.autoCompletePossibilities.removeAll()
                for snap in snapshot {
                    self.autoCompletePossibilities.append(snap.key)
                }
            }
        })
    }
    
    @IBAction func ingredientTextFieldEdited(_ sender: Any) {
        getAutoComplete()
    }

    
    func getAutoComplete() {
        autoComplete.removeAll()
        autoComplete.append(ingredientsTextField.text!)
        for key in autoCompletePossibilities {
            let capitalKey = key.capitalized
            let capitalIngredient = ingredientsTextField.text!.capitalized
            if(capitalKey.contains(capitalIngredient)) {
                if(capitalKey != capitalIngredient) {
                    autoComplete.append(key)
                }
            }
        }
        print(autoComplete)
        autoCompleteTableView.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    @IBAction func addButtonTapped(_ sender: Any) {
        if(ingredientsTextField.text != "")
        {
            ingredients.append(IngredientWithQuantity(quantity: quantity, ingredient: ingredientsTextField.text!, isOptional: isOptional))
            ingredientsTextField.text = ""
            self.view.endEditing(true)
        }
        tableView.reloadData()
        self.tableView.tableViewScrollToBottom(animated: true)
    }
    @IBAction func nextButtonTapped(_ sender: Any) {
        if(ingredients.count != 0) {
            self.performSegue(withIdentifier: "enterProcedureSegue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "enterProcedureSegue" {
            enterProcedureViewController = segue.destination as? EnterProcedureViewController
            enterProcedureViewController?.updateRecipeInformation(recipeTitle: _recipeTitle, recipeDescription: _recipeDescription, displayImage: _displayImage, ingredients: ingredients)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return ingredients.count
        }
        else if tableView == self.autoCompleteTableView {
            
            if(autoComplete.count >= 2) {
                self.view.removeGestureRecognizer(tap)
            }
            else {
                self.view.addGestureRecognizer(tap)
            }
            return autoComplete.count
            
        }
        else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.tableView {
            let ingredient = ingredients[indexPath.row]
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ingredientCell") as? IngredientTableViewCell {
                cell.configCell(ingredient: ingredient.ingredientWithQuantity)
                return cell
            }
            
            return IngredientTableViewCell()
            
        }
        else if tableView == self.autoCompleteTableView {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "autoCompleteCell") as? IngredientTableViewCell {
                let index = indexPath.row as Int
                cell.configCell(ingredient: autoComplete[index])
                print(autoComplete[index])
                return cell
            }
            return IngredientTableViewCell()
        }
        else {
            return IngredientTableViewCell()
        }
    }
    
    //selecting from autocomplete 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selection Made")
        if tableView == self.autoCompleteTableView {
            print("Selected Row")
            print(autoComplete[indexPath.row])
            print(indexPath.row)
            ingredientsTextField.text = autoComplete[indexPath.row]
            self.view.endEditing(true)
        }
    }
    
    // Show or hide autocomplete
    func textFieldDidBeginEditing(_ textField: UITextField) {
        getAutoComplete()
        autoCompleteTableView.reloadData()
        autoCompleteTableView.isHidden = false
        tableView.isHidden = true
        self.view.removeGestureRecognizer(tap)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        autoCompleteTableView.isHidden = true
        tableView.isHidden = false
        self.view.addGestureRecognizer(tap)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        if tableView == self.tableView {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            ingredients.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //UIPickerView
    @available(iOS 2.0, *)
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return quantityPickerData[component].count
    }
    
    // The data to return for the row and component (column) that's being passed in
    
    public func pickerView(_ pickerView: UIPickerView,
                           titleForRow row: Int,
                           forComponent component: Int) -> String? {
        return quantityPickerData[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        value = quantityPickerData[0][pickerView.selectedRow(inComponent: 0)]
        unit = quantityPickerData[1][pickerView.selectedRow(inComponent: 1)]
        
        if(component == 0) {
            value = quantityPickerData[0][row]
            setQuantityPickerData()
            if(row >= 2 && row <= 5) {
                setQuantityPickerDataToSingular()
                self.quantityPicker.reloadAllComponents()
            }
            else {
                
                self.quantityPicker.reloadAllComponents()
            }
            unit = quantityPickerData[1][pickerView.selectedRow(inComponent: 1)]
        }
        else if component == 1 {
            unit = quantityPickerData[1][row]
        }
        else {
            if row == 0 {
                isOptional = false
            }
            else {
                isOptional = true
            }
        }
        quantity = value + " " + unit
        quantity = quantity.replacingOccurrences(of: "  ", with: " ", options: .literal, range: nil)
        if unit == "" {
            quantity = quantity.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
            if quantity == "ToTaste" {
                quantity = "To Taste"
            }
        }
    }

}

extension UITableView {
    
    func tableViewScrollToBottom(animated: Bool) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            
            let numberOfSections = self.numberOfSections
            let numberOfRows = self.numberOfRows(inSection: numberOfSections-1)
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: animated)
            }
        }
    }
    func tableViewScrollToTop(animated: Bool) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            
            let numberOfSections = self.numberOfSections
            let numberOfRows = self.numberOfRows(inSection: numberOfSections-1)
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: animated)
            }
        }
    }
}

