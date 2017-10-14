//
//  CircieView.swift
//  Lingo_01
//
//  Created by WuKaipeng on 24/02/2017.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import UIKit

class PostProfileImageCircleView: UIImageView {
    
    override func layoutSubviews() {
        layer.cornerRadius = self.frame.width / 2
        clipsToBounds = true
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.flatRed.cgColor
    }
    
}

