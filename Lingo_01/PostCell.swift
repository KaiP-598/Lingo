//
//  PostCell.swift
//  Lingo_01
//
//  Created by WuKaipeng on 24/02/2017.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import UIKit
import Firebase

protocol ShowAlertcontroller:class {
    func showActionsheet(postKey: String, userID: String)
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
    weak var delegate: ShowAlertcontroller? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTapGestures()
        
        //setupActionSheet()
    }
    
    func setupTapGestures(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.isUserInteractionEnabled = true
        
//        let tap2 = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
//        tap2.numberOfTapsRequired = 1
//        commentImg.addGestureRecognizer(tap)
//        commentImg.isUserInteractionEnabled = true
//        
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
        
        self.caption.text = post.caption
        self.likeLbl.text = "\(post.likes)"
        self.caption.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0)
        self.timeLbl.text = timeStampHelper.timeManager.getTime(timeStamp: Int(post.timeStamp!)!)
        self.commentImg.isHidden = true
        self.shareImg.isHidden = true
        
        
        if (post.authorID != nil) {
            print ("xPost: \(post.caption)")
            userImageRef = DataService.ds.REF_USERS.child(post.authorID!).child("profile").child("profileImageUrl")
            userNameRef = DataService.ds.REF_USERS.child(post.authorID!).child("profile").child("username")
            
            //GET USERNAME FROM FIREBASE
            userNameRef.observeSingleEvent(of: .value, with: { (snapshot) in
                let userName = snapshot.value as? String ?? ""
                self.usernameLbl.text = userName
            })
            
            //GET IMAGE FROM FIREBASE
            userImageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                let profileImageUrl = snapshot.value as? String ?? ""
                let url = URL(string: "\(profileImageUrl)")!
                self.profileImg.kf.setImage(with: url)
//                let ref = FIRStorage.storage().reference(forURL: profileImageUrl)
//                ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
//                    if error != nil {
//                        print ("Log: Unable to download profile image")
//                    } else{
//                        print ("Log: Profile image downloaded successfully")
//                        if let imgData = data {
//                            if let userImage = UIImage(data: imgData){
//                                self.profileImg.image = userImage
//                                FeedVC.imageCache.setObject(userImage, forKey: profileImageUrl as NSString)
//                            }
//                        }
//                    }
//                })
            })
            
        } else{
            self.profileImg.image = UIImage(named: "profile")
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
        likesRef.observeSingleEvent(of: .value, with: {(snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "Hearts_Empty")
            } else {
                self.likeImg.image = UIImage(named: "Hearts_Filled")
            }
        
        })
    }
    
    func likeTapped(_ sender: UITapGestureRecognizer){
        likesRef.observeSingleEvent(of: .value, with: {(snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "Hearts_Filled")
                self.adjustLike(true)
                self.likesRef.setValue(true)
            } else {
                self.likeImg.image = UIImage(named: "Hearts_Empty")
                self.adjustLike(false)
                self.likesRef.removeValue()
            }
            
        })
    }
    
    func presentAlertcontroller(){
        delegate?.showActionsheet(postKey: self.post.postKey, userID: self.post.authorID!)
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
