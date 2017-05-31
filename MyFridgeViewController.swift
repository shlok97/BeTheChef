

import UIKit
import Firebase

var fridgeChanged = false

class MyFridgeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,  UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addIngredientTextField: UITextField!
    
    var itemsInFridge = [ItemInFridge]()
    var spinner = UIActivityIndicatorView()
    @IBOutlet weak var autoCompleteTableView: UITableView!
    
    //Auto Complete
    var autoCompletePossibilities = [String]()
    var autoComplete = [String]()
    
    var currentUser: User?
    let userID = FIRAuth.auth()?.currentUser?.uid
    var tap = UITapGestureRecognizer()
    override func viewDidLoad() {
        self.tableView.setLoadingScreen(spinner: &spinner)
        addIngredientTextField.delegate = self
        //self.hideKeyboardWhenTappedAround()
        refreshTable()
        autoCompleteTableView.delegate = self
        autoCompleteTableView.dataSource = self
        getIngredientsFromFirebase()
        tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        self.autoCompleteTableView.addGestureRecognizer(tap)
        self.tableView.addGestureRecognizer(tap)
        autoCompleteTableView.isHidden = true
    }
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(true)
        fridgeChanged = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.view.removeGestureRecognizer(tap)
        self.tableView.removeGestureRecognizer(tap)
        self.autoCompleteTableView.removeGestureRecognizer(tap)
    }
    
    func refreshTable() {
        getFromFirebase() { success in
            guard success == true
                else {
                //Do something if some error occured while retreiving data from firebase
                return
            }
            Timer.scheduledTimer(timeInterval: 0.2,
                                 target: self,
                                 selector: #selector(self.reloadTable),
                                 userInfo: nil,
                                 repeats: false)
            self.tableView.removeLoadingScreen(spinner: &self.spinner)
        }
    }
    
    //selecting from autocomplete
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selection Made")
        if tableView == self.autoCompleteTableView {
            print("Selected Row")
            print(autoComplete[indexPath.row])
            print(indexPath.row)
            addIngredientTextField.text = autoComplete[indexPath.row]
            self.view.endEditing(true)
        }
    }
    
    
    
    func reloadTable() {
        tableView.reloadData()
    }
    
    @IBOutlet weak var addItemToFridge: AddButton!
    
    @IBAction func addItemButtonTapped(_ sender: Any) {
        if (addIngredientTextField.text != "") {
            fridgeChanged = true
            let item = addIngredientTextField.text
            addIngredientTextField.text = ""
            postToFirebase(itemString: item!)
            refreshTable()
            self.view.endEditing(true)
            self.tableView.tableViewScrollToBottom(animated: true)
        }
    }
    
    func postToFirebase(itemString: String!) {
        
        let key = DataService.ds.REF_USERS.child(userID!).child("Items").childByAutoId().key
        
        var itemName = itemString!
        
        if(itemString == "Curd" || itemString == "Dahi") {
            itemName = "Yogurt"
        }
        
        let item: Dictionary<String, String> = [
            "itemName": itemName
        ]
        
        DataService.ds.REF_USERS.child(userID!).child("Items").child(key).setValue(item)
        //DataService.ds.REF_BASE.child("Ingredients").child(itemString).setValue(true)
    }
    
    func getFromFirebase(completion: @escaping (Bool) -> ()) {
        
        DataService.ds.REF_USERS.child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            if(snapshot.hasChild("Items")) {
                    print("Exists")
                DataService.ds.REF_USERS.child(self.userID!).child("Items").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let snaps = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    self.itemsInFridge.removeAll()
                        
                    for snap in snaps {
                        if let itemString = snap.value as? Dictionary<String, String> {
                            if (itemString["itemName"] != " ") {
                                
                                    self.itemsInFridge.append(ItemInFridge(itemKey: snap.key, itemName: itemString["itemName"]!))
                                    print(itemString["itemName"]!)
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                    self.tableView.removeLoadingScreen(spinner: &self.spinner)
                    completion(true)
                })
//                print("Items in Fridge: " + "\(self.itemsInFridge)")
            }
            else {
                print("Does not exist")
                self.tableView.removeLoadingScreen(spinner: &self.spinner)
            }
        })
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == self.tableView {
            return "ITEMS IN FRIDGE"
        }
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView {
            return itemsInFridge.count
        }
        else {
            return autoComplete.count
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.tableView {
            let ingredient = itemsInFridge[indexPath.row].itemName
            if let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell") as? RefrigeratorTableViewCell {
                let itemNumber = (Int(indexPath.row) % 5) + 1
                cell.configCell(ingredient: ingredient.capitalized, itemNumber: itemNumber)
                return cell
            }
            return IngredientTableViewCell()
        }
        else if tableView == self.autoCompleteTableView {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "autoCompleteCell") as? IngredientTableViewCell {
                let index = indexPath.row as Int
                cell.configCell(ingredient: autoComplete[index])
//                print(autoComplete[index])
                return cell
            }
            return IngredientTableViewCell()
        }
        return IngredientTableViewCell()
    }
    @IBAction func addItemTextFieldEdited(_ sender: Any) {
        getAutoComplete()
        autoCompleteTableView.reloadData()
    }
    
    // Deleting from table
    
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
            fridgeChanged = true
            DataService.ds.REF_USERS.child(userID!).child("Items").child(self.itemsInFridge[indexPath.row].itemKey).removeValue()
            if (itemsInFridge.count == 1) {
                itemsInFridge.removeAll()
                tableView.reloadData()
            }
            else {
                self.refreshTable()
            }
        }
    }
    
    // Show or hide autocomplete
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        getAutoComplete()
        //self.view.removeGestureRecognizer(tap)
        autoCompleteTableView.reloadData()
        autoCompleteTableView.isHidden = false
        tableView.isHidden = true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        autoComplete.removeAll()
        autoCompleteTableView.isHidden = true
        tableView.isHidden = false
        self.view.addGestureRecognizer(tap)
    }
    
    func getIngredientsFromFirebase() {
        
        DataService.ds.REF_BASE.child("Ingredients").observeSingleEvent(of: .value, with: {(snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                self.autoCompletePossibilities.removeAll()
                for snap in snapshot {
                    self.autoCompletePossibilities.append(snap.key)
                }
            }
        })
    }
    
    func getAutoComplete() {
        autoComplete.removeAll()
        autoComplete.append(addIngredientTextField.text!)
//        print(autoCompletePossibilities)
        for key in autoCompletePossibilities {
//            print("KEY: \(key)")
            let capitalKey = key.capitalized
            let capitalIngredient = addIngredientTextField.text!.capitalized
            if(capitalKey.contains(capitalIngredient)) {
                if(capitalKey != capitalIngredient) {
                    autoComplete.append(key)
                }
            }
        }
//        print(autoComplete.count)
        autoCompleteTableView.reloadData()
        
        if(autoComplete.count >= 2) {
            self.view.removeGestureRecognizer(tap)
        }
        else {
            self.view.addGestureRecognizer(tap)
        }
    }
    
}

extension UITableView {
    
}

