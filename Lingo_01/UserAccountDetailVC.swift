//
//  UserAccountDetailVC.swift
//  Lingo_01
//
//  Created by WuKaipeng on 13/03/2017.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import UIKit
import Firebase

class UserAccountDetailVC: UITableViewController {

    @IBOutlet weak var nameLabel: UILabel!
    
    var userNameRef: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        userNameRef = DataService.ds.REF_USER_CURRENT.child("profile").child("username")
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        obtainUserName()
    }
    

    func obtainUserName(){
        userNameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let userName = snapshot.value as? String ?? ""
            self.nameLabel.text = userName
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userName"{
            let userNameVC = segue.destination as! UserNameVC
            userNameVC.userName = self.nameLabel.text
        }
    }
}
