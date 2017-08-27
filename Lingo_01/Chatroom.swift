//
//  Chatroom.swift
//  Lingo_01
//
//  Created by WuKaipeng on 16/6/17.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import Foundation

class Chatroom {
    
    fileprivate var _chatroomID: String!
    fileprivate var _chatroomName: String!
    fileprivate var _chatroomLocationKey: String!
    
    
    var chatroomID: String {
        return _chatroomID
    }
    
    var chatroomName: String {
        return _chatroomName
    }
    
    var chatroomLocationKey: String {
        return _chatroomLocationKey
    }

    
    init(chatroomID: String,chatroomName: String, chatroomLocationKey: String ){
        self._chatroomID = chatroomID
        self._chatroomName = chatroomName
        self._chatroomLocationKey = chatroomLocationKey

    }
    
    init(chatroomKey: String, chatroomData: Dictionary<String,Any>){
        self._chatroomID = chatroomKey
        
        if let chatroomName = chatroomData["chatroomName"] as? String{
            self._chatroomName = chatroomName
        }
        
        if let chatroomLocationKey = chatroomData["chatroomLocationKey"] as? String{
            self._chatroomLocationKey = chatroomLocationKey
        }

    }
    
    
    
}
