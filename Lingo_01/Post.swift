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
    
    private var _imageUrl: String!
    private var _caption: String!
    private var _likes: Int!
    private var _postKey: String!
    private var _authorID: String!
    private var _timeStamp: String!
    private var _postRef: FIRDatabaseReference!
    
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
    
    var timeStamp: String? {
        return _timeStamp
    }
    
    init(caption: String, imageUrl: String, likes: Int, authorID: String, timeStamp: String){
        self._caption = caption
        self._imageUrl = caption
        self._likes = likes
        self._authorID = authorID
        self._timeStamp = timeStamp
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
        if let timeStamp = postData["timeStamp"] as? String{
            self._timeStamp = timeStamp
        }
        
        _postRef = DataService.ds.REF_POSTS.child(_postKey)
    }
    
    func adjustLikes(addLike: Bool) {
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        
        _postRef.child("likes").setValue(_likes)
    }
    
}
