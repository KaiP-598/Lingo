//
//  UserProfileVC.swift
//  Lingo_01
//
//  Created by WuKaipeng on 11/03/2017.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import UIKit

class UserProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImage: CircieView!
    
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self

        
    }

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
}
