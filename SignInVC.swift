//
//  ViewController.swift
//  BeTheChef
//
//  Created by Shlok Kapoor on 11/12/16.
//  Copyright © 2016 AppGali. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftKeychainWrapper

class SignInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID)
        {
            performSegue(withIdentifier: "signInSegue", sender: nil)
        }
    }

    @IBAction func signInButtonTapped(_ sender: Any) {
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self)
        {
            (result, error) in
            if(error != nil)
            {
                print("error")
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else if (result?.isCancelled)!
            {
                print("Error")
                let alert = UIAlertController(title: "Error", message: "Cancelled Task", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else
            {
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
                print("firebaseAuth")
                
            }
        }
        
    }
    
    func firebaseAuth(_ credential: FIRAuthCredential)
    {
        FIRAuth.auth()?.signIn(with: credential, completion: {
            (user, error) in
            if(error != nil)
            {
                print("Error")
            }
            else
            {
                print("Success!")
                if let user = user
                {
                    let userData = ["Name": user.displayName!]
                    self.completeSignIn(id: user.uid, userData: userData)
                }
                
            }
        })
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>)
    {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("Data saved to keychain \(keychainResult)")
        performSegue(withIdentifier: "signInSegue", sender: nil)
    }

}

