//
//  PostDownloadHelper.swift
//  Lingo_01
//
//  Created by WuKaipeng on 30/03/2017.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import Foundation
import Firebase

class PostDownloader{
    
    let postLocKey = PostLocationDateKey.manager.getCurrentDateKey()
    var circleQuery = GeoFire(firebaseRef: DataService.ds.REF_POSTS_LOC_DATE_KEY).query(at:nil, withRadius:5)!


    
    func getNearbyPosts(center: CLLocation, radius: Double, completionHandler: @escaping ([Post])->()){
        
        circleQuery.center = center
        circleQuery.radius = radius
        let dispatchGroup = DispatchGroup()
        let arrayQueue = DispatchQueue(label: "arrayQueue")
        var posts = [Post]()
        var queryHandle = circleQuery.observe(.keyEntered) { (postKey, location) in
            //dispatchGroup.enter()
            let postRef = DataService.ds.REF_POSTS.child(postKey!)
            postRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let postDict = snapshot.value as? Dictionary<String, Any>{
                    let key = snapshot.key
                    let post = Post(postKey: key, postData: postDict)
                    arrayQueue.sync {
                        posts.append(post)
                    }
                    
                }
                print ("debuggingg: \(posts)")
                //dispatchGroup.leave()
            })
        }
        dispatchGroup.notify(queue: DispatchQueue.main) {
           // print ("debuggingg: \(posts)")
            completionHandler(posts)
        }
        

    }
    static func getPostKeys(completionHandler: @escaping ([String])->()){
        //TODO CIRCLE QUERY
        var postKeys = [String]()
        let postLocationRef = DataService.ds.REF_POSTS_LOC_DATE_KEY
        
        postLocationRef.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshot {
                    let key = snap.key
                    postKeys.append(key)
                }
            }
            completionHandler(postKeys)
        })
        
    }
    
    static func getPost(postKeys:[String], completionHandler: @escaping ([Post])->()){
        var posts = [Post]()
        let dispatchGroup = DispatchGroup()
        let arrayQueue = DispatchQueue(label: "arrayQueue")
        for postKey in postKeys{
            dispatchGroup.enter()
            let postRef = DataService.ds.REF_POSTS.child(postKey)
            postRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let postDict = snapshot.value as? Dictionary<String, Any>{
                    let key = snapshot.key
                    let post = Post(postKey: key, postData: postDict)
                    arrayQueue.sync {
                        posts.append(post)
                    }
                    
                }
                dispatchGroup.leave()
            })
        }
        dispatchGroup.notify(queue: DispatchQueue.main) {
            completionHandler(posts)
        }
        
    }
    
    private func getIndividualPost(postKey: String)-> Post{
        let postRef = DataService.ds.REF_POSTS.child(postKey)
        var post: Post!
        postRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let postDict = snapshot.value as? Dictionary<String, Any>{
                let key = snapshot.key
                post = Post(postKey: key, postData: postDict)
            }
            
        })
        return post
    }
}
