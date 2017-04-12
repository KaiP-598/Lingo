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

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageAdd: CircieView!
    @IBOutlet weak var captionField: FancyField!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var testBtnLbl: UIButton!
    
    var posts = [Post]()
    var currentUser: FIRDatabaseReference!
    var locationManager: CLLocationManager!
    var geoFireUser: GeoFire!
    var geoFirePost: GeoFire!
    var currentUserLocation: CLLocation!
    var postDownloader = PostDownloader()
    var firstTimeForUserLocationSettup = true
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        currentUser = DataService.ds.REF_USER_CURRENT
        
        geoFireUser = GeoFire(firebaseRef: DataService.ds.REF_USERS_LOCATION)
        geoFirePost = GeoFire(firebaseRef: DataService.ds.REF_POSTS_LOCATIONS)
        
        PostDownloader.getPostKeys { (postKeys) in
            PostDownloader.getPost(postKeys: postKeys, completionHandler: { (posts) in
                self.posts = posts
                self.tableView.reloadData()
            })
        }
        
    
        
        
        
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
        setupUserLocation()
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
            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString){
                cell.configureCell(post: post, userLocation:currentUserLocation, img: img)
            } else{
                cell.configureCell(post: post, userLocation:currentUserLocation)
            }
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
        self.testBtnLbl.backgroundColor = UIColor.red
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[locations.count - 1]
        
        print ("location lat: \(userLocation.coordinate.latitude)")
        print ("location long: \(userLocation.coordinate.longitude)")
        currentUserLocation = userLocation
        updateUserLocationToFirebase(userLocation: userLocation)
        if !firstTimeForUserLocationSettup{
            postDownloader.getNearbyPosts(center: currentUserLocation, radius: 5.5) { (posts) in
                for p in posts{
                    // print ("debugging: \(p.postKey)")
                }
            }
        }
        firstTimeForUserLocationSettup = false
        
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
    
    func updateUserLocationToFirebase(userLocation: CLLocation){
        
        let uid = KeychainWrapper.stringForKey(KEY_UID)
        geoFireUser.setLocation(userLocation, forKey: uid){ (error) in
            if (error != nil){
                print ("Log: Error occured when updating user location to firebase")
            } else {
                print ("Log: User location updated to firebase successfully")
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toAddPostVC"){
            let addPostVC = segue.destination as! AddPostVC
            addPostVC.currentUserLocation = currentUserLocation
        }
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        let keychainResult = KeychainWrapper.removeObjectForKey(KEY_UID)
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "signOut", sender: nil)
        
        print (keychainResult)
    }
    
    @IBAction func test(_ sender: Any) {
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    @IBAction func test2(_ sender: Any) {
        self.testBtnLbl.backgroundColor = UIColor.red
    }

}
