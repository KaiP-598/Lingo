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
    var circleQuery = GeoFire(firebaseRef: DataService.ds.REF_CHATROOMS_LOC_DATE_KEY).query(at:nil, withRadius:25)!
    var delegate: SendChannelToChatroomVcDelegate?
    
    
    func getNearbyChatrooms(center: CLLocation, radius: Double){
        circleQuery.center = center
        circleQuery.radius = radius
        var queryHandle = circleQuery.observe(.keyEntered) { (chatroomKey, location) in
            print ("chatroomAdded:\(chatroomKey)")
            let chatroomRef = DataService.ds.REF_CHATROOMS.child(chatroomKey!)
            chatroomRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let chatroomDict = snapshot.value as? Dictionary<String, Any>{
                    let key = snapshot.key
                    let chatroom = Chatroom(chatroomKey: key, chatroomData: chatroomDict)
                    print ("chatroom added")
                    self.delegate?.sendChatroom(chatroom)
                }
            })
        }
    }
    
    func getExitedChatrooms(center: CLLocation, radius: Double){
        circleQuery.center = center
        circleQuery.radius = radius
        var queryHandle = circleQuery.observe(.keyExited) { (chatroomKey, location) in
            print ("exitedChatroomKey:\(chatroomKey)")
            self.delegate?.deleteChatroom(chatroomKey!)
        }
    }
}
