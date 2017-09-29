//
//  ViewcontrollerExtension.swift
//  Lingo_01
//
//  Created by WuKaipeng on 29/9/17.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import UIKit

extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
