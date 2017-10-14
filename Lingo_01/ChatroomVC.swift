//
//  ChatroomVC.swift
//  Lingo_01
//
//  Created by WuKaipeng on 16/6/17.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import ChameleonFramework
import SCLAlertView

class ChatroomVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, SendChannelToChatroomVcDelegate {

    @IBOutlet weak var createTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var geoFirePost: GeoFire!
    var geoFireUser: GeoFire!
    var senderDisplaynAME : String?
    var currentUserLocation: CLLocation!
    var loadedInitialChatrooms = false
    var locationManager: CLLocationManager!
    var chatroomDownloader = ChatroomDownloader()
    var selectedChatroom: Chatroom?
    var isAnonymous: Bool!
    private var chatrooms: [Chatroom] = []
    
    let numDays = PostLocationDateKey.manager.getCurrentDateKey()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // setupColor()
        setupUserLocation()
        self.tableView.backgroundColor = UIColor.init(hexString: "#F6F6F6")
        
        tableView.delegate = self
        tableView.dataSource = self
        chatroomDownloader.delegate = self
        
        geoFireUser = GeoFire(firebaseRef: DataService.ds.REF_USERS_LOCATION)
        geoFirePost = GeoFire(firebaseRef:DataService.ds.REF_CHATROOMS_LOCATION.child(numDays))
        

    }
    
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(true)
//        UIApplication.shared.statusBarStyle = .lightContent
//        
//    }
//    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
    

    func setupColor(){
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = FlatWhite()
        self.navigationController?.navigationBar.isTranslucent = true
        let titleDict = [NSForegroundColorAttributeName: FlatRed()]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatrooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chatroom = chatrooms[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "chatroomCell") as? ChatroomCell{
            cell.configureCells(chatroom: chatroom, location: currentUserLocation)
            return cell
            
        } else {
            return ChatroomCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        let chatroom = chatrooms[indexPath.row]
        if chatroom.isPublic == "true"{
            joinChatroom(chatroom: chatroom)
        } else {
            let appearance = SCLAlertView.SCLAppearance(
                kCircleIconHeight: 55.0,
                showCloseButton: false,
                showCircularIcon: true
                )
            let alertViewIcon = UIImage(named: "DefaultMask")
            let alert = SCLAlertView(appearance: appearance)
            let txt = alert.addTextField("Enter password")
            let submitButton = alert.addButton("Submit", action: {
                if txt.text == chatroom.password {
                    self.joinChatroom(chatroom: chatroom)
                } else {
                    let appearance = SCLAlertView.SCLAppearance(
                        showCloseButton: false
                    )
                    let alertView = SCLAlertView(appearance: appearance)
                    alertView.showWarning("Wrong password", subTitle: "", duration: 1.7)
                }
            })
            
            let cancelButton = alert.addButton("Cancel", action: {
                alert.dismiss(animated: true, completion: nil)
            })
            
            alert.showInfo("Enter password", subTitle: "This is a private chatroom",circleIconImage: alertViewIcon)
            submitButton.tintColor = UIColor.flatRed
            submitButton.backgroundColor = UIColor.flatRed
            cancelButton.backgroundColor = UIColor.flatRed
        }
    }
    
    func joinChatroom(chatroom: Chatroom){
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            
        }
        actionSheet.addAction(cancelAction)
        let myselfAction = UIAlertAction(title: "Enter As Myself", style: .default) { action in
            self.isAnonymous = false
            self.performSegue(withIdentifier: "ChatVC", sender: chatroom)
        }
        actionSheet.addAction(myselfAction)
        let anonymousAction = UIAlertAction(title: "Enter Anonymously", style: .default) { action in
            self.isAnonymous = true
            self.performSegue(withIdentifier: "ChatVC", sender: chatroom)
        }
        actionSheet.addAction(anonymousAction)
        present(actionSheet, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if (segue.identifier == "ChatVC"){
            if let chatroom = sender as? Chatroom{
                let chatVC = segue.destination as! ChatVC
                chatVC.chatroom = chatroom
                chatVC.isAnonymous = isAnonymous
            }
        } else if (segue.identifier == "toCreateChatroom"){
            let createChatroomVC = segue.destination as! CreateChatroomVC
            createChatroomVC.currentUserLocation = currentUserLocation
        }
    }
    
    func setupUserLocation(){
        //setup location manager properties
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1000.0
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print ("Error \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[locations.count - 1]
        
        currentUserLocation = userLocation
        updateUserLocationToFirebase(userLocation)
        if (loadedInitialChatrooms){
            chatroomDownloader.circleQuery.center = currentUserLocation
        } else{
            //if !firstTimeForUserLocationSettup{
            print ("locationCheck: \(currentUserLocation)")
            //chatrooms = []
            tableView.reloadData()
            chatroomDownloader.getNearbyChatrooms(center: currentUserLocation, radius: 25.5)
            chatroomDownloader.getExitedChatrooms(center: currentUserLocation, radius: 25.5)
            loadedInitialChatrooms = true
            //}
        }
    }
    
    func updateUserLocationToFirebase(_ userLocation: CLLocation){
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        geoFireUser.setLocation(userLocation, forKey: uid){ (error) in
            if (error != nil){
                print ("Log: Error occured when updating user location to firebase")
            } else {
                print ("Log: User location updated to firebase successfully")
            }
            
        }
    }
    
    func sendChatroom(_ chatroom: Chatroom) {
        print ("chatroom added2")
        tableView.beginUpdates()
        chatrooms.insert(chatroom, at: 0)
        let indexPath: IndexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    func deleteChatroom(_ chatroomKey: String) {
        for (index, chatroom) in chatrooms.enumerated(){
            if chatroomKey == chatroom.chatroomID{
                deleteChatroomAtRow(index)
            }
        }
    }
    
    func deleteChatroomAtRow(_ chatroomIndex: Int){
        tableView.beginUpdates()
        chatrooms.remove(at: chatroomIndex)
        let indexPath: IndexPath = IndexPath(row: chatroomIndex, section: 0)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    func createChatroomToFirebase(){
        //let timeInt = Int(Date().timeIntervalSince1970)
        let chatroom: Dictionary<String, AnyObject> = [
            "chatroomName": createTextField.text! as AnyObject,
            "chatroomCreator": KeychainWrapper.standard.string(forKey: KEY_UID) as AnyObject
        ]
        
        let firebasePost = DataService.ds.REF_CHATROOMS.childByAutoId()
        firebasePost.setValue(chatroom)
        geoFirePost.setLocation(currentUserLocation, forKey: firebasePost.key) { (error) in
            if let err = error{
                print ("unable to update location: \(err)")
            } else {
                print ("post location updated successfully")
            }
        }
        createTextField.text = ""
    }

    @IBAction func createRoomBtn(_ sender: Any) {
        guard let chatroomName = createTextField.text, chatroomName != "" else{
            print ("Log: chatroomName must be entered")
            return
        }
        createChatroomToFirebase()
    }

    @IBAction func createChatroomBtnPressed(_ sender: Any) {
        let appearance = SCLAlertView.SCLAppearance(
            kCircleIconHeight: 55.0,
            showCircularIcon: true
        )
        let alertView = SCLAlertView(appearance: appearance)
        let chatroomText = alertView.addTextField("Enter Chatroom name...")
        let passwordText = alertView.addTextField("Enter Password...")
        let alertViewIcon = UIImage(named: "DefaultMask") //Replace the IconImage text with the image name
        alertView.showInfo("Create Chatroom", subTitle: "Leave the password field blank to create a public chatroom", closeButtonTitle:"Cancel", circleIconImage: alertViewIcon)
    }

}
