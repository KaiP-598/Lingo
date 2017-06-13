//
//  ReportVC.swift
//  Lingo_01
//
//  Created by WuKaipeng on 26/05/2017.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import UIKit

class ReportVC: UIViewController {
    
    @IBOutlet weak var titleInput: UITextField!
    @IBOutlet weak var textviewInput: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func sendReportBtn(_ sender: Any) {
        let report: Dictionary<String, AnyObject> = [
            "title": titleInput.text! as AnyObject,
            "description": 	textviewInput.text! as AnyObject
        ]
        
        let firebasePost = DataService.ds.REF_REPORT.childByAutoId()
        firebasePost.setValue(report)
        textviewInput.text = "Report sent, you can retype to send another one"
        titleInput.text = ""	
        
    }



}
