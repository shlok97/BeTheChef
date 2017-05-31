//
//  UploadPhotoViewController.swift
//  BeTheChef
//
//  Created by Shlok Kapoor on 14/12/16.
//  Copyright © 2016 AppGali. All rights reserved.
//

import UIKit

class UploadPhotoViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var imageView: FoodImageView!
    var enterIngredientsViewController: EnterIngredientsViewController?
    @IBOutlet weak var descriptionPickerView: UIPickerView!
    
    var imageSelected = false
    
    var pickerData: [String] = ["Choose a category", "Breakfast", "Dessert", "Indian", "Indian Chinese", "Chinese", "Continental", "South Indian", "French", "American", "Italian American", "Italian", "Lebanese", "Arab", "Japanese", "Punjabi", "Rajasthani", "European", "Mexican", "Other"]
    
    var cuisine = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = #imageLiteral(resourceName: "default")
        
        self.titleTextField.delegate = self
        self.descriptionPickerView.delegate = self
        self.descriptionPickerView.dataSource = self
        descriptionPickerView.reloadAllComponents()
        self.hideKeyboardWhenTappedAround()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    @IBAction func uploadPicture(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        image.allowsEditing = true
        self.present(image, animated: true, completion: nil)
    }

    @IBAction func clickPicture(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.camera
        image.allowsEditing = true
        self.present(image, animated: true, completion: nil)
        print("Click Picture")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            imageView.image = image
            imageSelected = true
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextButtonTaped(_ sender: UIButton) {
        
        if ((titleTextField.text != "") && (descriptionPickerView.selectedRow(inComponent: 0) != 0)) {
            print(description)
            self.performSegue(withIdentifier: "enterIngredientsSegue", sender: self)
            
        }
    }
    
    //UIPickerView
    
    @available(iOS 2.0, *)
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in

    public func pickerView(_ pickerView: UIPickerView,
                           titleForRow row: Int,
                           forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        cuisine = pickerData[row]
        print(cuisine)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "enterIngredientsSegue" {
            print(cuisine)
            enterIngredientsViewController = segue.destination as? EnterIngredientsViewController
            if (imageSelected) {
                enterIngredientsViewController?.updateTitleAndDescription(recipeTitle: titleTextField.text!, recipeDescription: cuisine, displayImage: imageView.image!)
            }
            else {
                enterIngredientsViewController?.updateTitleAndDescription(recipeTitle: titleTextField.text!, recipeDescription: cuisine, displayImage: nil)
            }
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
