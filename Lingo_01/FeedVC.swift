//
//  FeedVC.swift
//  Lingo_01
//
//  Created by WuKaipeng on 23/02/2017.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase
import CoreData
import Kingfisher

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, SendPostToFeedVcDelegate, ShowAlertcontroller{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageAdd: CircieView!
    @IBOutlet weak var captionField: FancyField!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var posts = [Post]()
    var blocklist = [String]()
    var currentUser: FIRDatabaseReference!
    var locationManager: CLLocationManager!
    var geoFireUser: GeoFire!
    var geoFirePost: GeoFire!
    var currentUserLocation: CLLocation!
    var postDownloader = PostDownloader()
    var firstTimeForUserLocationSettup = false
    var loadedInitialPosts = false
    var alert = Alert()
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        currentUser = DataService.ds.REF_USER_CURRENT
        
        geoFireUser = GeoFire(firebaseRef: DataService.ds.REF_USERS_LOCATION)
        geoFirePost = GeoFire(firebaseRef: DataService.ds.REF_POSTS_LOCATIONS)
        
//        PostDownloader.getPostKeys { (postKeys) in
//            PostDownloader.getPost(postKeys: postKeys, completionHandler: { (posts) in
//                self.posts = posts
//                self.tableView.reloadData()
//            })
//        }
        
        postDownloader.delegate = self
        
        setupUserLocation()
        setupBlocklist()
//        DataService.ds.REF_POSTS.observe(.value, with: {(snapshot) in
//            
//            self.posts = []
//            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot]{
//                for snap in snapshot {
//                    if let postDict = snap.value as? Dictionary<String, Any>{
//                        let key = snap.key
//                        let post = Post(postKey: key, postData: postDict)
//                        self.posts.append(post)
//                    }
//                }
//            }
//            self.tableView.reloadData()
//        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell{
           // if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString){
//            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString){
//                cell.configureCell(post: post, userLocation:currentUserLocation, img: img)
//            } else{
//                cell.configureCell(post: post, userLocation:currentUserLocation)
//            }
            cell.delegate = self
            cell.configureCell(post: post, userLocation: currentUserLocation)
            return cell

        } else {
            return PostCell()
        }
        
        
    }
    
    func setupUserLocation(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1000.0
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[locations.count - 1]
        
        currentUserLocation = userLocation
        updateUserLocationToFirebase(userLocation)
        if (loadedInitialPosts){
            postDownloader.circleQuery.center = currentUserLocation
        } else{
            //if !firstTimeForUserLocationSettup{
                print ("postAdded: \(currentUserLocation)")
                //posts = []
                tableView.reloadData()
                postDownloader.getNearbyPosts(center: currentUserLocation, radius: 25.5)
                postDownloader.getExitedPosts(center: currentUserLocation, radius: 25.5)
                loadedInitialPosts = true
            //}
        }
        
       // firstTimeForUserLocationSettup = false
        
        //locationManager.stopUpdatingLocation()
        
//        let geoCoder = CLGeocoder()
//        geoCoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
//            if error != nil {
//                print ("Log: Error when converting user location to placemark")
//            } else {
//                let placeArray = placemarks as [CLPlacemark]!
//                var placeMark: CLPlacemark!
//                placeMark = placeArray?[0]
//                
//                print ("LogPlace: \(placeMark.addressDictionary)")
//                
//            }
//        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print ("Error \(error)")
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
    
    func sendPost(_ post: Post) {
        print ("postAddedSendPost:\(posts)")
        if (!self.blocklist.contains("\(post.authorID!)")){
            tableView.beginUpdates()
            posts.insert(post, at: 0)
            let indexPath: IndexPath = IndexPath(row: 0, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
        print ("paomian: \(self.posts.count)")
    }
    
    func deletePost(_ postKey: String){
        for (index, post) in posts.enumerated(){
            if postKey == post.postKey{
                deletePostAtRow(index)
            }
        }
    }
    
    func deletePostAtRow(_ postIndex: Int){
        tableView.beginUpdates()
        posts.remove(at: postIndex)
        let indexPath: IndexPath = IndexPath(row: postIndex, section: 0)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    func setupBlocklist(){
        DataService.ds.REF_USER_CURRENT.child("blocklist").observe(.value, with: {(snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshot {
                    self.blocklist.append(snap.key)
                }
            }
        })
    }
    
    func showActionsheet(postKey: String, userID: String) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            print(self.blocklist)
        }
        actionSheet.addAction(cancelAction)
        let blockAction = UIAlertAction(title: "Block User", style: .default) { action in
            let report: Dictionary<String, AnyObject> = [
                "\(userID)": "true" as AnyObject
            ]
            let blockList = DataService.ds.REF_USER_CURRENT.child("blocklist")
            blockList.setValue(report)
            self.deletePost(postKey)

        }
        actionSheet.addAction(blockAction)
        let reportAction = UIAlertAction(title: "Report", style: .destructive) { action in
            let report: Dictionary<String, AnyObject> = [
                "postKey": postKey as AnyObject,
                "userID": userID as AnyObject
            ]
            
            let firebasePost = DataService.ds.REF_REPORT.childByAutoId()
            firebasePost.setValue(report)
        }
        actionSheet.addAction(reportAction)
        present(actionSheet, animated: true, completion: nil)
    }
    
    func presentCommentVC(postKey: String) {
        performSegue(withIdentifier: "commentVC", sender: postKey)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toAddPostVC"){
            let addPostVC = segue.destination as! AddPostVC
            addPostVC.currentUserLocation = currentUserLocation
        } else if(segue.identifier == "commentVC"){
            if let postKey = sender as! String?{
                let commentVC = segue.destination as! CommentVC
                commentVC.postKey = postKey
            }
        }
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "signOut", sender: nil)
        
        print (keychainResult)
    }
    
    @IBAction func test(_ sender: Any) {
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    @IBAction func test2(_ sender: Any) {
       self.tableView.reloadData()
    }

}
