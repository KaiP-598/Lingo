//
//  PostCell.swift
//  Lingo_01
//
//  Created by WuKaipeng on 24/02/2017.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {
    
    
    @IBOutlet weak var profileImg: CircieView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var postImgHeightConstraint: NSLayoutConstraint!
    
    var post: Post!
    var likesRef: FIRDatabaseReference!
    var userNameRef: FIRDatabaseReference!
    var userImageRef: FIRDatabaseReference!

    override func awakeFromNib() {
        super.awakeFromNib()

        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.isUserInteractionEnabled = true
        
    }

    func configureCell(post: Post, img: UIImage? = nil) {
        self.post = post
        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
        
        self.caption.text = post.caption
        self.likeLbl.text = "\(post.likes)"
        self.caption.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        
        
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
                let ref = FIRStorage.storage().reference(forURL: profileImageUrl)
                ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                    if error != nil {
                        print ("Log: Unable to download profile image")
                    } else{
                        print ("Log: Profile image downloaded successfully")
                        if let imgData = data {
                            if let userImage = UIImage(data: imgData){
                                self.profileImg.image = userImage
                                FeedVC.imageCache.setObject(userImage, forKey: profileImageUrl as NSString)
                            }
                        }
                    }
                })
            })
            
        } else{
            self.profileImg.image = UIImage(named: "profile")
            self.usernameLbl.text = "Anonymous"
        }
        
        
        
        
        if img != nil{
            self.postImg.image = img
//            if self.postImg.frame.size.width < (img?.size.width)!{
//                self.postImgHeightConstraint.constant = self.postImg.frame.size.width / (img?.size.width)! * (img?.size.height)!
//            }
        } else{
            
            let ref = FIRStorage.storage().reference(forURL: post.imageUrl)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion:{(data, error) in
                if error != nil {
                    print ("JESS: Unable to download image from Firebase storage")
                } else{
                    print ("JESS: Image downloaded successful")
                    if let imgData = data {
                        if let img = UIImage(data: imgData){
//                            if self.postImg.frame.size.height < (img.size.height){
//                                self.postImgWidthConstraint.constant = self.postImg.frame.size.height / (img.size.height) * (img.size.width)
//                            }
                            self.postImg.image = img
//                            if self.postImg.frame.size.width < (img.size.width){
//                                self.postImgHeightConstraint.constant = self.postImg.frame.size.width / (img.size.width) * (img.size.height)
//                            }
                            FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                        }
                    }
                }
            })
        }
        
        //observe single event for the likes
        likesRef.observeSingleEvent(of: .value, with: {(snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "empty-heart")
            } else {
                self.likeImg.image = UIImage(named: "filled-heart")
            }
        
        })
    }
    
    func likeTapped(sender: UITapGestureRecognizer){
        likesRef.observeSingleEvent(of: .value, with: {(snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "filled-heart")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likeImg.image = UIImage(named: "empty-heart")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
            
        })
    }
    

    
}
