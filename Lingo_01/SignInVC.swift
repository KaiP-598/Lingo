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
import SkyFloatingLabelTextField

class SignInVC: UIViewController {

    @IBOutlet weak var emailField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var pwdField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var facebookBtn: UIButton!
    
    fileprivate enum loginType{
        case Facebook
        case Firebase
        case FirebaseSignUp
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        self.setupTextfields()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID){
            performSegue(withIdentifier: "goToTab", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTextfields(){
        self.emailField.iconFont = UIFont(name: "FontAwesome", size: 15)
        self.emailField.iconText = "\u{f0e0}"
        self.pwdField.iconFont = UIFont(name: "FontAwesome", size: 15)
        self.pwdField.iconText = "\u{f023}"
        self.facebookBtn.setTitle("  \u{f09a}  Login With Facebook", for: .normal)
        
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
                    let userData = ["provider":credential.provider, "profile":["username": "Anonymous", "profileImageUrl": "\(MASK_URL)"]] as [String : Any]
                    //self.completeSignIn(user.uid, userData: userData)
                    self.createAgreementAlert(type: .Facebook, userID: user.uid, userData: userData)
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
                        self.completeSignIn(user.uid, userData: userData)
                    }
                } else{
                    self.createAgreementAlert(type: .FirebaseSignUp, userID: "", userData: ["provider": "nil"])
                    
                }
            })
        }
        
    }
    
    func completeSignIn(_ id: String, userData: Dictionary<String, Any>){
        let userID = id
        let userDataGenerated = userData
        DataService.ds.createFirebaseUser(uid: userID, userData: userDataGenerated)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("JESS: Data saved to keychain \(keychainResult)")
        performSegue(withIdentifier: "goToTab", sender: nil)
    }
    
    fileprivate func createAgreementAlert(type: loginType, userID: String, userData:Dictionary<String,Any>){
       // let alert = UIAlertController(title: "Terms and Conditions", message: termsAndConditions, preferredStyle: .alert)
        
//        let margin:CGFloat = 8.0
//        //let rect = CGRect(margin, margin, alert.view.bounds.size.width - margin * 4.0, 100.0)
//        let rect = CGRect(x: margin, y: margin, width: alert.view.bounds.size.width - margin * 6.0, height: 100)
//        let customView = UITextView(frame: rect)
//        
//        customView.backgroundColor = UIColor.clear
//        customView.font = UIFont(name: "Helvetica", size: 15)
//        customView.text = termsAndConditions
//        
//        alert.view.addSubview(customView)
        
        //Cancel button
        //let cancelBtn = UIAlertAction(title: "Cancel", style: .destructive, handler: {(action) -> Void in})
        //Agree button
//        let agreeBtn = UIAlertAction(title: "Agree", style: .default) { (action) in
//            
//            if type == .FirebaseSignUp{
//                let email = self.emailField.text!
//                let pwd = self.pwdField.text!
//                
//                FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
//                    if error != nil {
//                        print ("JESS: Unable to authenticate with Firebase using email")
//                    } else{
//                        print ("JESS: Successfully authenticated with Firebase")
//                        if let user = user {
//                            let userData = ["provider":user.providerID, "profile":["username": "Anonymous", "profileImageUrl": "\(MASK_URL)"]] as [String : Any]
//                            self.completeSignIn(user.uid, userData: userData)
//                        }
//                    }
//                })
//            }else {
//                self.completeSignIn(userID, userData: userData)
//            }
//        }
        
        if type == .FirebaseSignUp{
            let email = self.emailField.text!
            let pwd = self.pwdField.text!
            
            FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                if error != nil {
                    print ("JESS: Unable to authenticate with Firebase using email")
                   // print ("\(error)")
                } else{
                    print ("JESS: Successfully authenticated with Firebase")
                    if let user = user {
                        let userData = ["provider":user.providerID, "profile":["username": "Anonymous", "profileImageUrl": "\(MASK_URL)"]] as [String : Any]
                        self.completeSignIn(user.uid, userData: userData)
                    }
                }
            })
            
            self.emailField.text = ""
            self.pwdField.text = ""
        }else {
            self.completeSignIn(userID, userData: userData)
            self.emailField.text = ""
            self.pwdField.text = ""
        }
        //alert.addAction(agreeBtn)
        //alert.addAction(cancelBtn)
        //present(alert, animated:true, completion:nil)
    }
    
    
    @IBAction func forgotPasswordBtnPressed(_ sender: Any) {
        
    }
}

