//
//  ChatroomVC.swift
//  Lingo_01
//
//  Created by WuKaipeng on 16/6/17.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

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
    private var chatrooms: [Chatroom] = []
    
    let numDays = PostLocationDateKey.manager.getCurrentDateKey()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUserLocation()
        
        tableView.delegate = self
        tableView.dataSource = self
        chatroomDownloader.delegate = self
        
        geoFireUser = GeoFire(firebaseRef: DataService.ds.REF_USERS_LOCATION)
        geoFirePost = GeoFire(firebaseRef:DataService.ds.REF_CHATROOMS_LOCATION.child(numDays))
        

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatrooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return ChatroomCell()
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
            chatrooms = []
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
        
    }
    
    func deleteChatroom(_ chatroomKey: String) {
        
    }
    
    func createChatroomToFirebase(){
        //let timeInt = Int(Date().timeIntervalSince1970)
        let chatroom: Dictionary<String, AnyObject> = [
            "chatroomName": createTextField.text! as AnyObject
        ]
        
        let firebasePost = DataService.ds.REF_CHATROOMS.childByAutoId()
        firebasePost.setValue(chatroom)
        geoFirePost.setLocation(currentUserLocation, forKey: firebasePost.key) { (error) in
            if error != nil{
                print ("unable to update location: \(error)")
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


}
