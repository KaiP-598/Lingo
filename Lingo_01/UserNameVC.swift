//
//  UserNameVC.swift
//  Lingo_01
//
//  Created by WuKaipeng on 13/03/2017.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import UIKit
import Firebase

class UserNameVC: UIViewController {
    
    @IBOutlet weak var nameField: FancyField!
    
    var userNameRef: FIRDatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()

        userNameRef = DataService.ds.REF_USER_CURRENT.child("profile").child("username")
        obtainUserName()
    }
    
    func obtainUserName(){
        //get user name from firebase
        
        userNameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let userName = snapshot.value as? String ?? ""
            self.nameField.text = userName
        })
        
    }
    

    @IBAction func saveBtnPressed(_ sender: Any) {
        
        guard let userName = nameField.text else {
            return
        }
        
        userNameRef.setValue(userName)
        
        //self.dismiss(animated: true, completion: nil)
        
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
}
