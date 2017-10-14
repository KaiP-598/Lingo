//
//  UserProfileVC.swift
//  Lingo_01
//
//  Created by WuKaipeng on 11/03/2017.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import NVActivityIndicatorView

class UserProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NVActivityIndicatorViewable {

    @IBOutlet weak var profileImage: CircieView!
    
    var imagePicker: UIImagePickerController!
    var profileImageRef: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        profileImageRef = DataService.ds.REF_USER_CURRENT.child("profile").child("profileImageUrl")

        obtainProfileImage()
    }
    
    func obtainProfileImage(){
        let defaults = UserDefaults.standard
        if let imageUrlString = defaults.string(forKey: "profileImageUrl"){
            let url = URL(string: "\(imageUrlString)")!
            self.profileImage.kf.setImage(with: url)
        }
        
        //GET IMAGE FROM FIREBASE
        profileImageRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let profileImageUrl = snapshot.value as? String ?? ""
            let url = URL(string: "\(profileImageUrl)")!
            self.profileImage.kf.setImage(with: url)
            defaults.set(profileImageUrl, forKey: "profileImageUrl")
//            let ref = FIRStorage.storage().reference(forURL: profileImageUrl)
//            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
//                if error != nil {
//                    print ("Log: Unable to download profile image")
//                } else{
//                    print ("Log: Profile image downloaded successfully")
//                    if let imgData = data {
//                        if let img = UIImage(data: imgData){
//                        self.profileImage.image = img
//                        }
//                    }
//                }
//            })
        })
    }
    

    
    //change profile image
    @IBAction func profileImageBtnTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImage.image = image
        } else{
            print ("Log: A valid image isn't selected")
        }
        imagePicker.dismiss(animated:true, completion: nil)
    }
    
    @IBAction func updateBtnTapped(_ sender: Any) {
        startAnimating(type: NVActivityIndicatorType.ballClipRotatePulse, color: UIColor.flatWatermelon)
        guard let img = profileImage.image else {
            self.stopAnimating()
            print ("Log: Error with the user profile image")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2){
            let imgUid = UUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
        
        
        DataService.ds.REF_USER_PROFILE_IMAGES.child(imgUid).put(imgData, metadata: metadata) {(metaData, error) in
            
            if error != nil {
                self.stopAnimating()
                print ("Log: Unable to upload image to Firebase storage")
            } else{
                
                print ("Log: Successfully uploaded image to Firebase storage")
                let downloadURL = metaData?.downloadURL()?.absoluteString
                if let url = downloadURL{
                    self.postToFirebase(url)
                }
            }
            
            }
    
    }
}
    
    func postToFirebase(_ imgUrl: String){
        profileImageRef.setValue(imgUrl)
        self.stopAnimating()
        print ("Log: Profile Image successfully updated")
        
    }
    

    @IBAction func logOutBtnTapped(_ sender: Any) {
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        try! FIRAuth.auth()?.signOut()
        print (keychainResult)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
}
