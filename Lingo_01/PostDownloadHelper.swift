//
//  PostDownloadHelper.swift
//  Lingo_01
//
//  Created by WuKaipeng on 30/03/2017.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import Foundation
import Firebase

protocol SendPostToFeedVcDelegate{
    func sendPost(post: Post)
    func deletePost(postKey: String)
}
class PostDownloader{
    
    let postLocKey = PostLocationDateKey.manager.getCurrentDateKey()
    var circleQuery = GeoFire(firebaseRef: DataService.ds.REF_POSTS_LOC_DATE_KEY).query(at:nil, withRadius:5)!
    var delegate: SendPostToFeedVcDelegate?

    
    func getNearbyPosts(center: CLLocation, radius: Double){
        circleQuery.center = center
        circleQuery.radius = radius
        var queryHandle = circleQuery.observe(.keyEntered) { (postKey, location) in
            print ("postAdded:\(postKey)")
            let postRef = DataService.ds.REF_POSTS.child(postKey!)
            postRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let postDict = snapshot.value as? Dictionary<String, Any>{
                    let key = snapshot.key
                    let post = Post(postKey: key, postData: postDict)
                    self.delegate?.sendPost(post: post)
                }
            })
        }
    }
    
    func getExitedPosts(center: CLLocation, radius: Double){
        circleQuery.center = center
        circleQuery.radius = radius
        var queryHandle = circleQuery.observe(.keyExited) { (postKey, location) in
            print ("postkey:\(postKey)")
            self.delegate?.deletePost(postKey: postKey!)
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
