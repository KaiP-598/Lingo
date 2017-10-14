//
//  ChatroomCell.swift
//  Lingo_01
//
//  Created by WuKaipeng on 16/6/17.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import UIKit

class ChatroomCell: UITableViewCell {

    @IBOutlet weak var chatroomImage: CircieView!
    @IBOutlet weak var chatroomName: UILabel!
    @IBOutlet weak var chatroomLocation: UILabel!
    @IBOutlet weak var chatroomLock: UIImageView!
    @IBOutlet weak var chatroomTimestamp: UILabel!
    
    var geoFirePost: GeoFire!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCells(chatroom: Chatroom, location: CLLocation? = nil){
        self.backgroundColor = UIColor.flatWhite
        var lockImage: UIImage
        if chatroom.isPublic == "true" {
            lockImage = UIImage(named: "UnlockChatroom")!
        } else {
            lockImage = UIImage(named: "LockChatroom")!
        }
        
        self.chatroomLock.image = lockImage
        self.chatroomName.text = chatroom.chatroomName
        self.chatroomTimestamp.text = timeStampHelper.timeManager.getTime(timeStamp: Int(chatroom.timestamp)!)
        
        let url = URL(string: "\(chatroom.chatroomImageUrl)")!
        self.chatroomImage.kf.setImage(with: url)
        
        let numDays = PostLocationDateKey.manager.getCurrentDateKey()
        geoFirePost = GeoFire(firebaseRef: DataService.ds.REF_CHATROOMS_LOCATION.child(numDays))
        
        if location != nil {
            geoFirePost.getLocationForKey(chatroom.chatroomID) { (chatroomLocation, error) in
                if (error != nil){
                    print ("Log: error when retrieving location for post")
                } else if (chatroomLocation != nil){
                    let chatroomLocation = chatroomLocation
                    let distanceInMeters = location?.distance(from: chatroomLocation!)
                    let distanceInKilo = Int(distanceInMeters!/1000)
                    self.chatroomLocation.text = "\(distanceInKilo)km"
                } else {
                    self.chatroomLocation.text = "unknown"
                }
            }
        }
    }

}
