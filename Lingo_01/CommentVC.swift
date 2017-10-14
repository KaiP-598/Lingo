//
//  CommentVC.swift
//  Lingo_01
//
//  Created by WuKaipeng on 13/6/17.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class CommentVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var commentRef: FIRDatabaseReference!
    var profileRef: FIRDatabaseReference!
    
    var postKey: String?
    var uid: String?
    var profileImgUrl: String?
    var userName: String?
    var comments = [Comment]()
    var blocklist = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.commentTextField.delegate = self
        
        profileRef = DataService.ds.REF_USER_CURRENT.child("profile")
        commentRef = DataService.ds.REF_COMMENT.child("\(postKey!)")
        uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        
        
        
        //push view when keyboard is shown
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        
        hideKeyboard()
        setupBlocklist()
        obtainProfile()
        obtainComments()

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
    }
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = comments[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as? CommentCell{
            
            cell.configureCell(comment: comment)
            
            return cell
            
        } else{
            return CommentCell()
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let report = UITableViewRowAction(style: .normal, title: "Report") { action, index in
            let comment = self.comments[index.row]
            self.showActionsheet(commentKey: comment.commentID, userID: comment.userID, indexPath: indexPath)
        }
        //let backImage = UIImageView(image: UIImage(named: "profile"))
       // backImage.contentMode = .scaleAspectFill
        //report.backgroundColor = UIColor(patternImage: backImage.image!)
        report.backgroundColor = UIColor(rgb: 0xC0C0C0)

        
        return [report]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func deleteCommentAtRow(_ commentIndexPath: IndexPath){
        tableView.beginUpdates()
        comments.remove(at: commentIndexPath.row)
        tableView.deleteRows(at: [commentIndexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    func showActionsheet(commentKey: String, userID: String, indexPath: IndexPath) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            
        }
        actionSheet.addAction(cancelAction)
        let blockAction = UIAlertAction(title: "Block User", style: .default) { action in
            let report: Dictionary<String, AnyObject> = [
                "\(userID)": "true" as AnyObject
            ]
            let blockList = DataService.ds.REF_USER_CURRENT.child("blocklist")
            blockList.setValue(report)
            self.deleteCommentAtRow(indexPath)
            
        }
        actionSheet.addAction(blockAction)
        let reportAction = UIAlertAction(title: "Report", style: .destructive) { action in
            let report: Dictionary<String, AnyObject> = [
                "postKey": commentKey as AnyObject,
                "userID": userID as AnyObject
            ]
            
            let firebasePost = DataService.ds.REF_REPORT.childByAutoId()
            firebasePost.setValue(report)
        }
        actionSheet.addAction(reportAction)
        present(actionSheet, animated: true, completion: nil)
    }
    
    func setupBlocklist(){
        DataService.ds.REF_USER_CURRENT.child("blocklist").observe(.value, with: {(snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshot {
                    self.blocklist[snap.key] = "true"
                }
            }
        })
    }
    
    func obtainProfile(){
        profileRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let profile = snapshot.value as? Dictionary<String, Any>{
                if let profileImgUrl = profile["profileImageUrl"] as? String{
                    self.profileImgUrl = profileImgUrl
                }
                
                if let userName = profile["username"] as? String{
                    self.userName = userName
                }
            }
        })
    }
    
    func obtainComments(){
        DataService.ds.REF_COMMENT.child("\(postKey!)").observe(.value, with: {(snapshot) in
            self.comments = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshot {
                    if let commentDict = snap.value as? Dictionary<String, Any>{
                        let key = snap.key
                        let comment = Comment(commentID: key, commentData: commentDict)
                        if self.blocklist[comment.userID] == nil{
                            self.comments.append(comment)
                        }
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    
    @IBAction func postBtnTapped(_ sender: Any) {
        if let commentText = commentTextField.text{
            if commentText == ""{
                return
            }
            
            let timeInt = Int(Date().timeIntervalSince1970)
            let comment: Dictionary<String, AnyObject> = [
                "content": commentText as AnyObject,
                "profileImg": self.profileImgUrl as AnyObject,
                "userID": uid! as AnyObject,
                "username": self.userName as AnyObject,
                "timeStamp": "\(timeInt)" as AnyObject
                
            ]
            
            let firebasePost = DataService.ds.REF_COMMENT.child("\(self.postKey!)").childByAutoId()
            firebasePost.setValue(comment)
            self.commentTextField.text = ""
            dismissKeyboard()
            
        }
    }
    
    func keyboardWillShow(sender: NSNotification) {
        //self.view.frame.origin.y = -150  Move view 150 points upward
        
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                print (keyboardSize.height)
                //self.view.frame.origin.y -= keyboardSize.height
                let duration:TimeInterval = (sender.userInfo![UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
                let animationCurveRawNSN = sender.userInfo![UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
                let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
                let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
                self.bottomConstraint?.constant = keyboardSize.height
                UIView.animate(withDuration: duration,
                               delay: TimeInterval(0),
                               options: animationCurve,
                               animations: { self.view.layoutIfNeeded() },
                               completion: nil)
            }
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
               // self.view.frame.origin.y += keyboardSize.height
            
            }
        }
        self.bottomConstraint?.constant = 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commentTextField.resignFirstResponder()
        return true
    }
    
}
