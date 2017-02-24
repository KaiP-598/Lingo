//
//  ViewController.swift
//  Lingo_01
//
//  Created by WuKaipeng on 11/02/2017.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import SwiftKeychainWrapper

class SignInVC: UIViewController {

    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var pwdField: FancyField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.stringForKey(KEY_UID){
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func facebookBtnTapped(_ sender: Any) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) {(result, error) in
        if error != nil {
            print ("JESS: Unable to autheticate with Facebook - \(error)")
        } else if result?.isCancelled == true {
            print ("JESS: User cancelled Facebook authentication")
        }
        else{
            print ("JESS: Successfully authenticated with Facebook")
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            
            self.firebaseAuth(credential)
            }
        }
        
    }
    
    func firebaseAuth(_ credential: FIRAuthCredential){
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print ("JESS: Unable to authenticate with Firebase - \(error)")
                
            } else {
                print ("JESS: Successfully authenticated with Firebase")
                if let user = user {
                    let userData = ["provider":credential.provider]
                    self.completeSignIn(id: user.uid, userData: userData)
                }
            }
        })
    }

    @IBAction func signInTapped(_ sender: Any) {
        if let email = emailField.text, let pwd = pwdField.text{
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil{
                    print ("JESS: Email User authenticated with Firebase")
                    if let user = user {
                        let userData = ["provider":user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else{
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            print ("JESS: Unable to authenticate with Firebase using email")
                        } else{
                            print ("JESS: Successfully authenticated with Firebase")
                            if let user = user {
                                let userData = ["provider":user.providerID]
                                self.completeSignIn(id: user.uid, userData: userData)
                            }
                        }
                    })
                }
            })
        }
        
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>){
        DataService.ds.createFirebaseUser(uid: id, userData: userData)
        let keychainResult = KeychainWrapper.setString(id, forKey: KEY_UID)
        print("JESS: Data saved to keychain \(keychainResult)")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
}

