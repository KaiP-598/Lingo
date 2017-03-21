//
//  AddPostVC.swift
//  Lingo_01
//
//  Created by WuKaipeng on 21/03/2017.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import UIKit
import Firebase

class AddPostVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var addedImage: UIImageView!
    @IBOutlet weak var captionField: UITextField!
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    var currentUser: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initImagePicker()
        currentUser = DataService.ds.REF_USER_CURRENT

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
        }
        imagePicker.dismiss(animated:true, completion: nil)
    }
    
    func postToFirebase(imgUrl: String){
        let post: Dictionary<String, AnyObject> = [
            "caption": captionField.text! as AnyObject,
            "imageUrl": imgUrl as AnyObject,
            "likes": 0 as AnyObject,
            "userID": currentUser.key as AnyObject
            
        ]
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        captionField.text = ""
        imageSelected = false
        addedImage.image = UIImage(named: "add-image")
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func addImageBtnTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func cancelBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func shareBtnTapped(_ sender: Any) {
        guard let caption = captionField.text, caption != "" else{
            print ("Log: Caption must be entered")
            return
        }
        guard let img = addedImage.image, imageSelected == true else {
            print ("Log: An image must be selected")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2){
            
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_POST_IMAGES.child(imgUid).put(imgData, metadata: metadata) {(metaData, error) in
                
                if error != nil {
                    print ("Log: Unable to upload image to Firebase storage")
                } else {
                    print ("Log: Successfully uploaded image to Firebase storage")
                    let downloadURL = metaData?.downloadURL()?.absoluteString
                    if let url = downloadURL{
                        self.postToFirebase(imgUrl: url)
                    }
                    
                }
                
            }
        }
    }
}
