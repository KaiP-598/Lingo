//
//  UserAccountDetailVC.swift
//  Lingo_01
//
//  Created by WuKaipeng on 13/03/2017.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import UIKit

class UserAccountDetailVC: UITableViewController {

    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      //  userNameLabel.text = "sadasds"

    }
    
    override func viewDidAppear(_ animated: Bool) {
        nameLabel.text = "String"
    }
    


}
