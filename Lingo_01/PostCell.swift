//
//  PostCell.swift
//  Lingo_01
//
//  Created by WuKaipeng on 24/02/2017.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

protocol ShowAlertcontroller:class {
    func showActionsheet(postKey: String, userID: String)
    func presentCommentVC(postKey: String)
}

class PostCell: UITableViewCell {
    
    
    @IBOutlet weak var profileImg: CircieView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var postImgHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var commentImg: UIImageView!
    @IBOutlet weak var shareImg: UIImageView!
    @IBOutlet weak var bookmarkImg: UIImageView!
    
    var post: Post!
    var likesRef: FIRDatabaseReference!
    var userNameRef: FIRDatabaseReference!
    var userImageRef: FIRDatabaseReference!
    var postRef: FIRDatabaseReference!
    var geoFirePost: GeoFire!
    var actionSheet: UIAlertController!
    var currentUser : String!
    weak var delegate: ShowAlertcontroller? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTapGestures()
        currentUser = KeychainWrapper.standard.string(forKey: KEY_UID)
        //setupActionSheet()
    }
    
    func setupTapGestures(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.isUserInteractionEnabled = true
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(presentCommentVC))
        tap2.numberOfTapsRequired = 1
        commentImg.addGestureRecognizer(tap2)
        commentImg.isUserInteractionEnabled = true
        
//        let tap3 = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
//        tap3.numberOfTapsRequired = 1
//        shareImg.addGestureRecognizer(tap)
//        shareImg.isUserInteractionEnabled = true
//        
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(presentAlertcontroller))
        tap4.numberOfTapsRequired = 1
        bookmarkImg.addGestureRecognizer(tap4)
        bookmarkImg.isUserInteractionEnabled = true
        
    }
    func configureCell(post: Post, userLocation: CLLocation? = nil) {
        self.post = post
        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
        postRef = DataService.ds.REF_POSTS.child(self.post.postKey)
        let numDays = PostLocationDateKey.manager.getCurrentDateKey()
        geoFirePost = GeoFire(firebaseRef: DataService.ds.REF_POSTS_LOCATIONS.child(numDays))
        
        self.usernameLbl.text = post.authorName
        self.caption.text = post.caption
        self.likeLbl.text = "\(post.likes)"
        self.caption.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0)
        self.timeLbl.text = timeStampHelper.timeManager.getTime(timeStamp: Int(post.timeStamp!)!)
        self.shareImg.isHidden = true
        
        
        if (post.authorID != nil && post.isAnonymous == "false") {
            if let userProfileImageUrl = post.profileImageUrl {
                let url = URL(string: userProfileImageUrl)
                self.profileImg.kf.setImage(with: url)
            }
        } else{
            self.profileImg.image = UIImage(named: "DefaultMask")
            self.usernameLbl.text = "Anonymous"
        }
        
        let url = URL(string: "\(post.imageUrl)")!
        self.postImg.kf.setImage(with: url)
        
        
//        if img != nil{
//            self.postImg.image = img
////            if self.postImg.frame.size.width < (img?.size.width)!{
////                self.postImgHeightConstraint.constant = self.postImg.frame.size.width / (img?.size.width)! * (img?.size.height)!
////            }
//        } else{
//            
//            let ref = FIRStorage.storage().reference(forURL: post.imageUrl)
//            ref.data(withMaxSize: 2 * 1024 * 1024, completion:{(data, error) in
//                if error != nil {
//                    print ("JESS: Unable to download image from Firebase storage")
//                } else{
//                    print ("JESS: Image downloaded successful")
//                    if let imgData = data {
//                        if let img = UIImage(data: imgData){
////                            if self.postImg.frame.size.height < (img.size.height){
////                                self.postImgWidthConstraint.constant = self.postImg.frame.size.height / (img.size.height) * (img.size.width)
////                            }
//                            self.postImg.image = img
////                            if self.postImg.frame.size.width < (img.size.width){
////                                self.postImgHeightConstraint.constant = self.postImg.frame.size.width / (img.size.width) * (img.size.height)
////                            }
//                            FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
//                        }
//                    }
//                }
//            })
//        }
        
        if userLocation != nil {
            geoFirePost.getLocationForKey(post.postKey) { (location, error) in
                if (error != nil){
                    print ("Log: error when retrieving location for post")
                } else if (location != nil){
                    let postLocation = location
                    let distanceInMeters = userLocation?.distance(from: postLocation!)
                    let distanceInKilo = Int(distanceInMeters!/1000)
                    print("distance: \(distanceInKilo)")
                    self.distanceLbl.text = "\(distanceInKilo)km"
                } else {
                    print ("Log: Geofire does not contain a location for \(post.postKey)")
                    self.distanceLbl.text = "unknown"
                }
            }
        }
        
        //observe single event for the likes
//        likesRef.observeSingleEvent(of: .value, with: {(snapshot) in
//            if let _ = snapshot.value as? NSNull {
//                self.likeImg.image = UIImage(named: "Heart-Gray")
//            } else {
//                self.likeImg.image = UIImage(named: "Heart-Red")
//            }
//
//        })
        
        
        if let likesByDictionary = post.likesByDict{
            if let val = likesByDictionary[currentUser!] as? String{
                if val == "true"{
                    self.likeImg.image = UIImage(named: "Heart-Red")
                } else {
                    self.likeImg.image = UIImage(named: "Heart-Gray")
                }
            }
        } else {
            self.likeImg.image = UIImage(named: "Heart-Gray")
        }
        
    }
    
    func likeTapped(_ sender: UITapGestureRecognizer){
        likesRef.observeSingleEvent(of: .value, with: {(snapshot) in
            if let _ = snapshot.value as? NSNull {
              //  self.likeImg.image = UIImage(named: "Heart-Red")
               // self.adjustLike(true)
                self.likesRef.setValue(true)
            } else {
              //  self.likeImg.image = UIImage(named: "Heart-Gray")
               // self.adjustLike(false)
                self.likesRef.removeValue()
            }
            
        })

        if var likesByDictionary = post.likesByDict{
            if let val = likesByDictionary[currentUser!] as? String{
                var likesByDict : Dictionary<String, AnyObject> = [
                    "\(currentUser!)" : "false" as AnyObject
                ]
                if val == "true" {
                    self.likeImg.image = UIImage(named: "Heart-Gray")
                    self.adjustLike(false)
                    likesByDict[currentUser!] = "false" as AnyObject
                    likesByDictionary[currentUser!] = "false" as AnyObject
                    post.likesByDict = likesByDictionary
                } else {
                    self.likeImg.image = UIImage(named: "Heart-Red")
                    self.adjustLike(true)
                    likesByDict[currentUser!] = "true" as AnyObject
                    likesByDictionary[currentUser!] = "true" as AnyObject
                    post.likesByDict = likesByDictionary
                }
                postRef.child("likesBy").updateChildValues(likesByDict)
            }
            else {
                let likesByDict : Dictionary<String, AnyObject> = [
                    "\(currentUser!)" : "true" as AnyObject
                ]
                self.likeImg.image = UIImage(named: "Heart-Red")
                self.adjustLike(true)
                likesByDictionary[currentUser!] = "true" as AnyObject
                post.likesByDict = likesByDictionary
                postRef.child("likesBy").updateChildValues(likesByDict)
            }
            
        } else {
            let likesByDict : Dictionary<String, AnyObject> = [
                "\(currentUser!)" : "true" as AnyObject
            ]
            self.likeImg.image = UIImage(named: "Heart-Red")
            self.adjustLike(true)
            post.likesByDict = likesByDict
            postRef.child("likesBy").updateChildValues(likesByDict)
        }
    }
    
    func presentAlertcontroller(){
        delegate?.showActionsheet(postKey: self.post.postKey, userID: self.post.authorID!)
    }
    
    func presentCommentVC(){
        delegate?.presentCommentVC(postKey: self.post.postKey)
    }
    
    //quicker UI response but not effective
    func adjustLike(_ addLike: Bool){
        var likes = Int(self.likeLbl.text!)
        if addLike{
            likes = likes! + 1
        } else {
            likes = likes! - 1
        }
        self.likeLbl.text = "\(likes!)"
        postRef.child("likes").observeSingleEvent(of: .value, with: { (snapshot) in
            var postLikes: Int!
            if let like = snapshot.value as? Int{
                if addLike{
                    postLikes = like + 1
                } else {
                    postLikes = like - 1
                }
                self.postRef.child("likes").setValue(postLikes!)
            }
        })
        
    }
    
    //Safer way to adjust likes but slower because getting firebase datafirst
    func adjustLikes(_ addLike: Bool){
        var likes:Int!
        postRef.child("likes").observeSingleEvent(of: .value, with: { (snapshot) in
            if let like = snapshot.value as? Int{
                if addLike{
                    likes = like + 1
                } else {
                    likes = like - 1
                }
                self.likeLbl.text = "\(likes!)"
                self.postRef.child("likes").setValue(likes!)
            }
        })
    }
    

    
}
