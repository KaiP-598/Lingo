//
//  RoundBtn.swift
//  Lingo_01
//
//  Created by WuKaipeng on 11/02/2017.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import UIKit

class ProfileCircleButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = self.frame.width / 2
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.white.cgColor
    }
    
    
    
    
}
