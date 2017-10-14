//
//  AddPostVC.swift
//  Lingo_01
//
//  Created by WuKaipeng on 21/03/2017.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import NVActivityIndicatorView
import SCLAlertView

class AddPostVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, NVActivityIndicatorViewable {

    @IBOutlet weak var addedImage: UIImageView!
    @IBOutlet weak var captionField: UITextField!
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    var currentUser: FIRDatabaseReference!
    var currentUserLocation: CLLocation?
    var geoFirePost: GeoFire!
    var geoFirePostNextDay: GeoFire!
    
    let numDays = PostLocationDateKey.manager.getCurrentDateKey()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initImagePicker()
        currentUser = DataService.ds.REF_USER_CURRENT
        let numDayPlusOne = String(Int(numDays)! + 1)
        geoFirePost = GeoFire(firebaseRef:DataService.ds.REF_POSTS_LOCATIONS.child(numDays))
        geoFirePostNextDay = GeoFire(firebaseRef:DataService.ds.REF_POSTS_LOCATIONS.child(numDayPlusOne))
    }
    
    func initImagePicker(){
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            addedImage.image = image
            imageSelected = true
        } else{
            print ("Log: A valid image isn't selected")
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            addedImage.image = image
        }
        imagePicker.dismiss(animated:true, completion: nil)
    }
    
    func postToFirebase(_ imgUrl: String, isAnonymous: String, userName: String, profileImageUrl: String){
        let timeInt = Int(Date().timeIntervalSince1970)
        
        let post: Dictionary<String, AnyObject> = [
            "caption": captionField.text! as AnyObject,
            "imageUrl": imgUrl as AnyObject,
            "likes": 0 as AnyObject,
            "userID": currentUser.key as AnyObject,
            "userName": userName as AnyObject,
            "userProfileImageUrl": profileImageUrl as AnyObject,
            "timeStamp": "\(timeInt)" as AnyObject,
            "isAnonymous": isAnonymous as AnyObject
        ]
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        geoFirePost.setLocation(currentUserLocation, forKey: firebasePost.key) { (error) in
            if error != nil{
                self.stopAnimating()
                print ("unable to update location: \(error)")
            } else {
                print ("post location updated successfully")
            }
        }
        geoFirePostNextDay.setLocation(currentUserLocation, forKey: firebasePost.key) { (error) in
            if error != nil{
               self.stopAnimating()
                print ("unable to update location: \(error)")
            } else {
                print ("post location updated successfully")
            }
        }
        captionField.text = ""
        imageSelected = false
        addedImage.image = UIImage(named: "add-image")
        stopAnimating()
        self.dismiss(animated: true, completion: nil)
    }
    
    func sharePost(isAnonymous: String){
        startAnimating(type: NVActivityIndicatorType.ballClipRotatePulse, color: UIColor.flatWatermelon)
        guard let caption = captionField.text, caption != "" else{
            print ("Log: Caption must be entered")
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false,
                titleColor: UIColor.flatRedDark
            )
            let alertView = SCLAlertView(appearance: appearance)
            alertView.showWarning("", subTitle: "The caption cannot be empty", duration: 1.5)
            stopAnimating()
            return
        }
        guard let img = addedImage.image, imageSelected == true else {
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false,
                titleColor: UIColor.flatRedDark
            )
            let alertView = SCLAlertView(appearance: appearance)
            alertView.showWarning("", subTitle: "We need an image for the post", duration: 1.5)
            stopAnimating()
            print ("Log: An image must be selected")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.5){
            
            let imgUid = UUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_POST_IMAGES.child(imgUid).put(imgData, metadata: metadata) {(metaData, error) in
                
                if error != nil {
                    self.stopAnimating()
                    print ("Log: Unable to upload image to Firebase storage")
                } else {
                    print ("Log: Successfully uploaded image to Firebase storage")
                    let downloadURL = metaData?.downloadURL()?.absoluteString
                    if let url = downloadURL{
                        self.currentUser.child("profile").child("username").observeSingleEvent(of: .value, with: { (snapshot) in
                            let userName = snapshot.value as? String ?? ""
                            self.currentUser.child("profile").child("profileImageUrl").observeSingleEvent(of: .value, with: { (snapshot) in
                                    let profileImageUrl = snapshot.value as? String ?? ""
                                    self.postToFirebase(url, isAnonymous: isAnonymous, userName: userName, profileImageUrl: profileImageUrl)
                            })
                        })
                        
                    }
                    
                }
                
            }
        }
    }
    
    @IBAction func addImageBtnTapped(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            
        }
        actionSheet.addAction(cancelAction)
        let cameraOption = UIAlertAction(title: "Take A Photo", style: .default) { action in
            if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                self.present(self.imagePicker, animated: true, completion:nil)
            }
        }
        actionSheet.addAction(cameraOption)
        let photoAlbumOption = UIAlertAction(title: "From Camera Roll", style: .default) { action in
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(self.imagePicker, animated: true, completion:nil)
        }
        actionSheet.addAction(photoAlbumOption)
        present(actionSheet, animated: true, completion: nil)
    }

    @IBAction func cancelBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func shareBtnTapped(_ sender: Any) {
        //sharePost(userID: currentUser.key)
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in

        }
        actionSheet.addAction(cancelAction)
        let myselfAction = UIAlertAction(title: "Post As Myself", style: .default) { action in
            self.sharePost(isAnonymous: "false")
        }
        actionSheet.addAction(myselfAction)
        let anonymousAction = UIAlertAction(title: "Post Anonymously", style: .default) { action in
            self.sharePost(isAnonymous: "true")
        }
        actionSheet.addAction(anonymousAction)
        present(actionSheet, animated: true, completion: nil)
    }
}
