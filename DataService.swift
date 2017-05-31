//
//  DataService.swift
//  BeTheChef
//
//  Created by Shlok Kapoor on 14/12/16.
//  Copyright © 2016 AppGali. All rights reserved.
//

import Foundation
import Firebase
import SwiftKeychainWrapper

let DB_BASE = FIRDatabase.database().reference()
let STORAGE_BASE = FIRStorage.storage().reference()

class DataService {
    static var ds = DataService()
    
    // DB REFERENCE
    private var _REF_BASE = DB_BASE
    private var _REF_RECIPES = DB_BASE.child("recipes")
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_INGREDIENTS = DB_BASE.child("recipes").child("ingredients")
    
    //STORAGE REFERENCES
    private var _REF_RECIPES_IMAGES = STORAGE_BASE.child("recipe-pics")
    
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_RECIPES: FIRDatabaseReference {
        debugPrint("yo1",_REF_RECIPES);
        return _REF_RECIPES
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    var REF_INGREDIENTS: FIRDatabaseReference {
        return _REF_INGREDIENTS
    }
    
    var REF_USERS_CURRENT: FIRDatabaseReference {
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        return REF_USERS.child(uid!)
    }
    
    var REF_RECIPES_IMAGES: FIRStorageReference {
        return _REF_RECIPES_IMAGES
    }
    
    func createFirebaseDBUser(uid: String, userData: Dictionary<String, String>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
}
