//
//  Post.swift
//  Lingo_01
//
//  Created by WuKaipeng on 25/02/2017.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    fileprivate var _imageUrl: String!
    fileprivate var _caption: String!
    fileprivate var _likes: Int!
    fileprivate var _postKey: String!
    fileprivate var _authorID: String!
    fileprivate var _authorName: String!
    fileprivate var _profileImageUrl: String!
    fileprivate var _timeStamp: String!
    fileprivate var _isAnonymous: String!
    fileprivate var _likesByDict: Dictionary<String, AnyObject>!
    fileprivate var _postRef: FIRDatabaseReference!
    
    var caption: String {
        return _caption
    }
    
    var imageUrl: String {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var postKey: String {
        return _postKey
    }
    
    var authorID: String? {
        return _authorID
    }
    
    var authorName: String? {
        return _authorName
    }
    
    var profileImageUrl: String? {
        return _profileImageUrl
    }
    
    var timeStamp: String? {
        return _timeStamp
    }
    
    var isAnonymous: String? {
        return _isAnonymous
    }
    
    var likesByDict: Dictionary<String, AnyObject>? {
        get{
            return _likesByDict
        }
        set{
            _likesByDict = newValue
        }
        
    }
    
    init(caption: String, imageUrl: String, likes: Int, authorID: String, timeStamp: String, isAnonymous: String){
        self._caption = caption
        self._imageUrl = caption
        self._likes = likes
        self._authorID = authorID
        self._timeStamp = timeStamp
        self._isAnonymous = isAnonymous
    }
    
    init(postKey: String, postData: Dictionary<String,Any>){
        self._postKey = postKey
        
        if let caption = postData["caption"] as? String{
            self._caption = caption
        }
        
        if let imageUrl = postData["imageUrl"] as? String{
            self._imageUrl = imageUrl
        }
        
        if let likes = postData["likes"] as? Int{
            self._likes = likes
        }
        
        if let authorID = postData["userID"] as? String {
            self._authorID = authorID
        }
        
        if let authorName = postData["userName"] as? String {
            self._authorName = authorName
        }
        
        if let profileImageUrl = postData["userProfileImageUrl"] as? String {
            self._profileImageUrl = profileImageUrl
        }
        
        if let timeStamp = postData["timeStamp"] as? String{
            self._timeStamp = timeStamp
        }
        
        if let isAnonymous = postData["isAnonymous"] as? String{
            self._isAnonymous = isAnonymous
        }
        
        if let likesByDict = postData["likesBy"] as? Dictionary<String, AnyObject>{
            self._likesByDict = likesByDict
        }
        
        _postRef = DataService.ds.REF_POSTS.child(_postKey)
    }
    
    func adjustLikes(_ addLike: Bool) {
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        
        _postRef.child("likes").setValue(_likes)
    }
    
}
