//
//  ChatroomVC.swift
//  Lingo_01
//
//  Created by WuKaipeng on 16/6/17.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import UIKit

class ChatroomVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var createTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    var senderDisplaynAME : String?
    private var chatrooms: [Chatroom] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatrooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return ChatroomCell()
    }

    @IBAction func createRoomBtn(_ sender: Any) {
    }


}
