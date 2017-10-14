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
    fileprivate var _chatroomCreator: String!
    fileprivate var _chatroomImageUrl: String!
    fileprivate var _isPublic: String!
    fileprivate var _password: String!
    fileprivate var _timestamp: String!
    
    
    var chatroomID: String {
        return _chatroomID
    }
    
    var chatroomName: String {
        return _chatroomName
    }
    
    var chatroomLocationKey: String {
        return _chatroomLocationKey
    }
    
    var chatroomCreator: String {
        return _chatroomCreator
    }
    
    var chatroomImageUrl: String {
        return _chatroomImageUrl
    }
    
    var isPublic: String {
        return _isPublic
    }
    
    var password: String {
        return _password
    }
    
    var timestamp: String {
        return _timestamp
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
        
        if let chatroomCreator = chatroomData["chatroomCreator"] as? String{
            self._chatroomCreator = chatroomCreator
        }
        
        if let chatroomImageUrl = chatroomData["imageUrl"] as? String{
            self._chatroomImageUrl = chatroomImageUrl
        }
        
        if let isPublic = chatroomData["isPublic"] as? String{
            self._isPublic = isPublic
        }
        
        if let password = chatroomData["password"] as? String{
            self._password = password
        }
        
        if let timestamp = chatroomData["timeStamp"] as? String{
            self._timestamp = timestamp
        }


    }
    
    
    
}
