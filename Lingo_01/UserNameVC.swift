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
    var userName: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        userNameRef = DataService.ds.REF_USER_CURRENT.child("profile").child("username")

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let userNameText = userName{
            self.nameField.text = userNameText
        }
    }
    

    @IBAction func saveBtnPressed(_ sender: Any) {
        
        //update user name
        guard let userName = nameField.text else {
            return
        }
        
        userNameRef.setValue(userName)
        
        //self.dismiss(animated: true, completion: nil)
        
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
}
