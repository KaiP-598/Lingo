//
//  CreateChatroomVC.swift
//  Lingo_01
//
//  Created by WuKaipeng on 3/9/17.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import UIKit
import ChameleonFramework
import SkyFloatingLabelTextField
import SCLAlertView
import Firebase
import SwiftKeychainWrapper
import NVActivityIndicatorView

class CreateChatroomVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, NVActivityIndicatorViewable {

    @IBOutlet weak var chatroomText: SkyFloatingLabelTextField!    
    @IBOutlet weak var chatroomPasswordText: SkyFloatingLabelTextField!
    @IBOutlet weak var chatroomImage: ProfileCircieView!
    
    //variables
    var imagePicker: UIImagePickerController!
    var currentUserLocation: CLLocation!
    var geoFirePost: GeoFire!
    
    //constants
    let numDays = PostLocationDateKey.manager.getCurrentDateKey()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // self.navigationItem.hidesBackButton = true
        //self.chatroomText.textAlignment = .center
        self.chatroomText.delegate = self
        self.chatroomPasswordText.delegate = self
        self.hideKeyboard()
        initImagePicker()
        setupGeoFire()
    }
    
    func initImagePicker(){
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
       // imagePicker.allowsEditing = true
    }
    
    func setupGeoFire(){
        geoFirePost = GeoFire(firebaseRef:DataService.ds.REF_CHATROOMS_LOCATION.child(numDays))
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            chatroomImage.image = image
        }
        imagePicker.dismiss(animated:true, completion: nil)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func createChatroom(url: String) {
        let timeInt = Int(Date().timeIntervalSince1970)
        var isPublic = "true"
        if chatroomPasswordText.text != "" {
            isPublic = "false"
        }
        let chatroom: Dictionary<String, AnyObject> = [
            "chatroomName": chatroomText.text! as AnyObject,
            "imageUrl": url as AnyObject,
            "chatroomCreator": KeychainWrapper.standard.string(forKey: KEY_UID) as AnyObject,
            "timeStamp": "\(timeInt)" as AnyObject,
            "isPublic": isPublic as AnyObject,
            "password": chatroomPasswordText.text! as AnyObject
        ]
        
        let chatroomRef = DataService.ds.REF_CHATROOMS.childByAutoId()
        chatroomRef.setValue(chatroom)
        
        geoFirePost.setLocation(currentUserLocation, forKey: chatroomRef.key) { (error) in
            if let err = error{
                print ("unable to update location: \(err)")
            } else {
                print ("post location updated successfully")
            }
        }
        self.stopAnimating()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createButtonPressed(_ sender: Any) {
        startAnimating(type: NVActivityIndicatorType.ballClipRotatePulse, color: UIColor.flatWatermelon)
        guard let chatroomName = chatroomText.text, chatroomName != "" else{
            print ("Log: Caption must be entered")
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false,
                titleColor: UIColor.flatRedDark
            )
            let alertView = SCLAlertView(appearance: appearance)
            alertView.showWarning("", subTitle: "We need a name for the chatroom", duration: 1.5)
            self.stopAnimating()
            return
        }
        
        guard let img = chatroomImage.image else {
            print ("Log: An image must be selected")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.5){
            
            let imgUid = UUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_CHATROOM_IMAGES.child(imgUid).put(imgData, metadata: metadata) {(metaData, error) in
                
                if error != nil {
                    print ("Log: Unable to upload image to Firebase storage")
                    self.stopAnimating()
                } else {
                    print ("Log: Successfully uploaded image to Firebase storage")
                    let downloadURL = metaData?.downloadURL()?.absoluteString
                    if let url = downloadURL{
                       self.createChatroom(url: url)
                    }
                    
                }
                
            }
        }
        
        
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
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
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}
