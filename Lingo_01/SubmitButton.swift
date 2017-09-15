//
//  RoundBtn.swift
//  Lingo_01
//
//  Created by WuKaipeng on 11/02/2017.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import UIKit

class SubmitButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.flatRed.cgColor
        layer.cornerRadius = 15
    }
    
    
    
    
}
