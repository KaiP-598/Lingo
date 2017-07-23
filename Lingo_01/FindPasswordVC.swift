//
//  FindPasswordVC.swift
//  Lingo_01
//
//  Created by WuKaipeng on 22/7/17.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import UIKit
import Firebase

class FindPasswordVC: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }

    @IBAction func sendBtnPressed(_ sender: Any) {
        if let email = emailTextField.text{
            FIRAuth.auth()?.sendPasswordReset(withEmail: email, completion: { (error) in
                if error != nil{
                    
                }
                else{
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
