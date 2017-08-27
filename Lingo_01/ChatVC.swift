//
//  ChatVC.swift
//  Lingo_01
//
//  Created by WuKaipeng on 29/6/17.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController
import SwiftKeychainWrapper
import Photos
import Kingfisher

class ChatVC: JSQMessagesViewController {

    var chatroomRef: FIRDatabaseReference?
    var photoRef: FIRStorageReference?
    var userNameRef: FIRDatabaseReference!
    var profileImageRef: FIRDatabaseReference!
    var anonymousRef: FIRDatabaseReference!
    private var messageRef: FIRDatabaseReference?
    private var newMessageRefHandle: FIRDatabaseHandle?
    private var updatedMessageRefHandle: FIRDatabaseHandle?
    private var anonymousRefHandle: FIRDatabaseHandle?
    private var photoMessageMap = [String: JSQPhotoMediaItem]()
    var chatroom: Chatroom?
    var theSenderDisplayname: String?
    var isAnonymous: Bool?
    var chatroomCreatorID: String?
    var messages = [JSQMessage]()
    var anonymousList = [String]()
    var anonymousDict = [String: String]()
    var senderAvatarDict = [String: String]()
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    private let imageURLNotSetKey = "NOTSET"
    
    deinit {
        if let refHandle = newMessageRefHandle {
            messageRef?.removeObserver(withHandle: refHandle)
        }
        
        if let refHandle = updatedMessageRefHandle {
            messageRef?.removeObserver(withHandle: refHandle)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFirebaseRef()
        obtainChatroomCreatorID()
        uploadAnonymousStatusToFirebase()
        getAnonymousList()
        observeMessages()
        obtainUserName()
        observeChatroomDeletion()

//        let navigationBarHeight: CGFloat = self.navigationController!.navigationBar.frame.height
//        let navigationBarHeight2: CGFloat = (self.navigationController?.navigationBar.intrinsicContentSize.height)!
//        self.collectionView?.contentInset.top = navigationBarHeight
//        
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        return messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource? {
        let message = messages[indexPath.item]
        if message.senderId == senderId() {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        //Decide display of the sender name
        let message = messages[indexPath.item]
        let anonymousVal = anonymousDict[message.senderId] as! String
        if message.senderId == senderId() {
            return nil
        }
        //if the item is sent by an anonymous person
        else if (anonymousVal == "true")
        {
            return NSAttributedString(string: "Anonymous")
        }
        else {
            print ("\(message.senderDisplayName)")
            return NSAttributedString(string: message.senderDisplayName)
            
        }
    }


    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat {
        //sender name height
        let message = messages[indexPath.item]
        //decide the sender name label height
        if message.senderId == senderId() {
            return 0.0
        } else {
            
            return 27.0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        let anonymousVal = anonymousDict[message.senderId]!
        if message.senderId == senderId() {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        cell.avatarImageView?.clipsToBounds = true
        cell.avatarImageView?.layer.cornerRadius = cell.avatarImageView!.frame.size.height / 2.2
        if anonymousVal == "true"{
            let avatarImg = UIImage(named: "DefaultMask")
            cell.avatarImageView?.image = avatarImg
        } else if let url = senderAvatarDict[message.senderId] {
            let kfUrl = URL(string: "\(url)")!
            cell.avatarImageView?.kf.setImage(with: kfUrl)
        }
        else{
            profileImageRef = DataService.ds.REF_USERS.child("\(message.senderId)").child("profile").child("profileImageUrl")
            profileImageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                let profileImageUrl = snapshot.value as? String ?? ""
                self.senderAvatarDict[message.senderId] = profileImageUrl
                let url = URL(string: "\(profileImageUrl)")!
                cell.avatarImageView?.kf.setImage(with: url)
            })
        }

        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> (JSQMessageAvatarImageDataSource!) {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, didTapAvatarImageView avatarImageView: UIImageView, at indexPath: IndexPath) {
        print ("\(indexPath.row)")
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func senderId() -> String {
        return KeychainWrapper.standard.string(forKey: KEY_UID)!
    }
    
    override func senderDisplayName() -> String {
        return theSenderDisplayname!
    }
    
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        let itemRef = messageRef?.childByAutoId()
        let messageItem = [ // 2
            "senderId": senderId,
            "senderName": senderDisplayName,
            "text": text
            ]
        
        itemRef?.setValue(messageItem)
        //JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            
        }
        actionSheet.addAction(cancelAction)
        let cameraOption = UIAlertAction(title: "Take A Photo", style: .default) { action in
            if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
                picker.sourceType = UIImagePickerControllerSourceType.camera
                self.present(picker, animated: true, completion:nil)
            }
        }
        actionSheet.addAction(cameraOption)
        let photoAlbumOption = UIAlertAction(title: "From Camera Roll", style: .default) { action in
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(picker, animated: true, completion:nil)
        }
        actionSheet.addAction(photoAlbumOption)
        present(actionSheet, animated: true, completion: nil)
//        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
//            picker.sourceType = UIImagePickerControllerSourceType.camera
//        } else {
//            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
//        }

    }
    
    func setupFirebaseRef(){
        userNameRef = DataService.ds.REF_USER_CURRENT.child("profile").child("username")
        chatroomRef = DataService.ds.REF_CHATROOMS.child("\(chatroom!.chatroomID)")
        if let chatroomReference = chatroomRef{
            messageRef = chatroomReference.child("messages")
            anonymousRef = chatroomReference.child("anonymous")
        }
        
        photoRef = DataService.ds.REF_CHAT_IMAGES
    }
    
    func obtainChatroomCreatorID(){
        chatroomRef?.child("chatroomCreator").observeSingleEvent(of: .value, with: { (snapshot) in
            let chatroomCreator = snapshot.value as? String ?? ""
            self.chatroomCreatorID = chatroomCreator
        })
    }
    
    func obtainUserName(){
        userNameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let userName = snapshot.value as? String ?? ""
            self.theSenderDisplayname = userName
        })
    }
    
    func observeChatroomDeletion() {
        DataService.ds.REF_CHATROOMS_LOC_DATE_KEY.child("\(chatroom!.chatroomID)").observeSingleEvent(of: .childRemoved, with: { (snapshot) in
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    func uploadAnonymousStatusToFirebase(){
        let statusItem = [ // 2
            "\(senderId())": "\(isAnonymous!)",
        ]
        anonymousRef.updateChildValues(statusItem)
    }
    
    func getAnonymousList(){
        anonymousRefHandle = anonymousRef.observe(.childAdded, with: { (snapshot) -> Void in
            let anonymousID = snapshot.key
            let messageData = snapshot.value as! String
            self.anonymousDict[anonymousID] = messageData
            print (self.anonymousDict)
        })
    }
    
    private func observeMessages() {
        let messageQuery = messageRef!.queryLimited(toLast:25)
        
        // 2. We can use the observe method to listen for new
        // messages being written to the Firebase DB
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            // 3
            let messageData = snapshot.value as! Dictionary<String, String>
            
            if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String!, text.characters.count > 0 {
                // 4
                self.addMessage(withId: id, name: name, text: text)
                
                // 5
                self.finishReceivingMessage()
            }
            else if let id = messageData["senderId"] as String!,
                let photoURL = messageData["photoURL"] as String! { // 1
                // 2
                
                print("QSAA\(photoURL)")
                let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId())
                    // 3
                self.addPhotoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem)
                    // 4
                if photoURL.hasPrefix("gs://") {
                    self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                }
                
            }
            else {
                print("Error! Could not decode message data")
            }
        })
        
        updatedMessageRefHandle = messageRef!.observe(.childChanged, with: { (snapshot) in
            let key = snapshot.key
            let messageData = snapshot.value as! Dictionary<String, String> // 1
            
            if let photoURL = messageData["photoURL"] as String! { // 2
                // The photo has been updated.
                if let mediaItem = self.photoMessageMap[key] { // 3
                    self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key) // 4
                }
            }
        })
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        let message = JSQMessage(senderId: id, displayName: name, text: text)
        messages.append(message)
       // anonymousList.append("\(isAnonymous!)")
    }
    
    private func addPhotoMessage(withId id: String, key: String, mediaItem: JSQPhotoMediaItem) {
      let message = JSQMessage(senderId: id, displayName: "", media: mediaItem)
      messages.append(message)
      //anonymousList.append("\(isAnonymous!)")
        
      if (mediaItem.image == nil) {
          photoMessageMap[key] = mediaItem
      }
        
      collectionView?.reloadData()

    }
    
    private func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
        // 1
        let storageRef = FIRStorage.storage().reference(forURL: photoURL)
        
        // 2
        storageRef.data(withMaxSize: INT64_MAX){ (data, error) in
            if let error = error {
                print("Error downloading image data: \(error)")
                return
            }
            
            // 3
            storageRef.metadata(completion: { (metadata, metadataErr) in
                if let error = metadataErr {
                    print("Error downloading metadata: \(error)")
                    return
                }
                
                // 4
//                if (metadata?.contentType == "image/gif") {
//                    mediaItem.image = UIImage.gifWithData(data!)
//                } else {
//                    mediaItem.image = UIImage.init(data: data!)
//                }
                mediaItem.image = UIImage.init(data: data!)
                self.collectionView?.reloadData()
                
                // 5
                guard key != nil else {
                    return
                }
                self.photoMessageMap.removeValue(forKey: key!)
            })
        }
    }
    
    func sendPhotoMessage() -> String? {
        let itemRef = messageRef!.childByAutoId()
        
        let messageItem = [
            "photoURL": imageURLNotSetKey,
            "senderId": senderId()
            ]
        
        itemRef.setValue(messageItem)
        
        //JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        return itemRef.key
    }
    
    func setImageURL(_ url: String, forPhotoMessageWithKey key: String) {
        print("QQQ\(url)")
        let itemRef = messageRef!.child(key)
        itemRef.updateChildValues(["photoURL": url])
    }
    
    private func setupOutgoingBubble()-> JSQMessagesBubbleImage{
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }

    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    @IBAction func moreBtnPressed(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if chatroomCreatorID == self.senderId() {
            let deleteAction = UIAlertAction(title: "Delete Chatroom", style: .destructive) { action in
                DataService.ds.REF_CHATROOMS_LOC_DATE_KEY.child("\(self.chatroom!.chatroomID)").removeValue()
            }
            actionSheet.addAction(deleteAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            
        }
        actionSheet.addAction(cancelAction)
        present(actionSheet, animated: true, completion: nil)
    }
    
}

extension ChatVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion:nil)
        
        if let photoReferenceUrl = info[UIImagePickerControllerReferenceURL] as? URL {
            // Handle picking a Photo from the Photo Library
            // 2
            let assets = PHAsset.fetchAssets(withALAssetURLs: [photoReferenceUrl], options: nil)
            let asset = assets.firstObject
            
            // 3
            if let key = sendPhotoMessage() {
                // 4
                asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
                    let imageFileURL = contentEditingInput?.fullSizeImageURL
                    // 5
                    let path = "\(KeychainWrapper.standard.string(forKey: KEY_UID)!)/\(Int64(Date.timeIntervalSinceReferenceDate * 1000))/\(photoReferenceUrl.lastPathComponent)"
                    
                    // 6
                    self.photoRef!.child(path).putFile(imageFileURL!, metadata: nil) { (metadata, error) in
                        if let error = error {
                            print("Error uploading photo: \(error.localizedDescription)")
                            return
                        }
                        // 7
                        print ("SSS\(metadata?.path)")
                        self.setImageURL(STORAGE_BASE.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                    }
                })
            }
        } else {
            // Handle picking a Photo from the Camera - TODO
            // 1
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            // 2
            if let key = sendPhotoMessage() {
                // 3
                let imageData = UIImageJPEGRepresentation(image, 1.0)
                // 4
                let imagePath = KeychainWrapper.standard.string(forKey: KEY_UID)! + "/\(Int64(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
                // 5
                let metadata = FIRStorageMetadata()
                metadata.contentType = "image/jpeg"
                // 6
                photoRef!.child(imagePath).put(imageData!, metadata: metadata) { (metadata, error) in
                    if let error = error {
                        print("Error uploading photo: \(error)")
                        return
                    }
                    // 7
                    self.setImageURL(STORAGE_BASE.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                }
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
}
