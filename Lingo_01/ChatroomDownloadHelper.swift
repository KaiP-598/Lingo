//
//  ChatroomDownloadHelper.swift
//  Lingo_01
//
//  Created by WuKaipeng on 20/6/17.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import Foundation
import Firebase

protocol SendChannelToChatroomVcDelegate{
    func sendChatroom(_ chatroom: Chatroom)
    func deleteChatroom(_ chatroomKey: String)
}
class ChatroomDownloader{
    
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
                    self.delegate?.sendPost(post)
                }
            })
        }
    }
    
    func getExitedPosts(center: CLLocation, radius: Double){
        circleQuery.center = center
        circleQuery.radius = radius
        var queryHandle = circleQuery.observe(.keyExited) { (postKey, location) in
            print ("postkey:\(postKey)")
            self.delegate?.deletePost(postKey!)
        }
    }
}
