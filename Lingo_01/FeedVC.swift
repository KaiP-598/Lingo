//
//  FeedVC.swift
//  Lingo_01
//
//  Created by WuKaipeng on 23/02/2017.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase

class FeedVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        let keychainResult = KeychainWrapper.removeObjectForKey(KEY_UID)
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "signOut", sender: nil)
    }

}
