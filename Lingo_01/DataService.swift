//
//  DataService.swift
//  Lingo_01
//
//  Created by WuKaipeng on 24/02/2017.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import Foundation
import Firebase
import SwiftKeychainWrapper


let DB_BASE = FIRDatabase.database().reference()
let STORAGE_BASE = FIRStorage.storage().reference()
let MASK_URL = "https://firebasestorage.googleapis.com/v0/b/lingo-79b76.appspot.com/o/user-profile-pics%2FDefaultMask.jpg?alt=media&token=2a6832de-fcf1-4838-9ef8-5d270152cdbd"

class DataService{
    
    static let ds = DataService()
    
    //DB References
    fileprivate var _REF_BASE = DB_BASE
    fileprivate var _REF_POSTS = DB_BASE.child("posts")
    fileprivate var _REF_POSTS_LOCATIONS = DB_BASE.child("posts_locations")
    fileprivate var _REF_USERS = DB_BASE.child("users")
    fileprivate var _REF_USERS_LOCATION = DB_BASE.child("users_locations")
    
    //Storage references
    fileprivate var _REF_POST_IMAGES = STORAGE_BASE.child("post-pics")
    fileprivate var _REF_USER_PROFILE_IMAGES = STORAGE_BASE.child("user-profile-pics")
    
    var REF_BASE : FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_POSTS : FIRDatabaseReference {
        return _REF_POSTS
    }
    
    var REF_POSTS_LOCATIONS: FIRDatabaseReference {
        return _REF_POSTS_LOCATIONS
    }
    
    var REF_POSTS_LOC_DATE_KEY: FIRDatabaseReference {
        return _REF_POSTS_LOCATIONS.child("\(PostLocationDateKey.manager.getCurrentDateKey())")
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    var REF_USER_CURRENT: FIRDatabaseReference {
        //let uid = KeychainWrapper.stringForKey(KEY_UID)
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        let user = REF_USERS.child(uid!)
        return user
    }
    
    var REF_USERS_LOCATION: FIRDatabaseReference {
        return _REF_USERS_LOCATION
    }
    
    var REF_POST_IMAGES: FIRStorageReference{
        return _REF_POST_IMAGES
    }
    
    var REF_USER_PROFILE_IMAGES: FIRStorageReference{
        return _REF_USER_PROFILE_IMAGES
    }
    
    
    
    func createFirebaseUser(uid: String, userData: Dictionary<String, Any>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
}
