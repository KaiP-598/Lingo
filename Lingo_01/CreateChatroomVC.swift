//
//  CreateChatroomVC.swift
//  Lingo_01
//
//  Created by WuKaipeng on 3/9/17.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import UIKit
import ChameleonFramework

class CreateChatroomVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       // self.navigationItem.hidesBackButton = true
    }
    
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}
