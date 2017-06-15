//
//  Comment.swift
//  Lingo_01
//
//  Created by WuKaipeng on 13/6/17.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import Foundation

class Comment {
    
    fileprivate var _imageUrl: String!
    fileprivate var _content: String!
    fileprivate var _timeStamp: String!
    fileprivate var _userName: String!
    fileprivate var _userID: String!
    fileprivate var _commentID: String!
    
    var content: String {
        return _content
    }
    
    var imageUrl: String {
        return _imageUrl
    }
    
    var userName: String {
        return _userName
    }
    
    var userID: String {
        return _userID
    }
    
    var commentID: String {
        return _commentID
    }
    
    var timeStamp: String? {
        return _timeStamp
    }
    
    init(content: String, imageUrl: String, timeStamp: String, username: String, userID: String){
        self._content = content
        self._imageUrl = imageUrl
        self._userName = username
        self._timeStamp = timeStamp
        self._userID = userID
    }
    
    init(commentID: String, commentData: Dictionary<String,Any>){
        self._commentID = commentID
        
        if let content = commentData["content"] as? String{
            self._content = content
        }
        
        if let imageUrl = commentData["profileImg"] as? String{
            self._imageUrl = imageUrl
        }
        
        if let userName = commentData["username"] as? String{
            self._userName = userName
        }
        
        if let userID = commentData["userID"] as? String{
            self._userID = userID
        }

        if let timeStamp = commentData["timeStamp"] as? String{
            self._timeStamp = timeStamp
        }
        
    }
    
}
