//
//  CircieView.swift
//  Lingo_01
//
//  Created by WuKaipeng on 24/02/2017.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import UIKit

class ProfileCircieView: UIImageView {
    
    override func layoutSubviews() {
        layer.cornerRadius = self.frame.width / 2
        clipsToBounds = true
        layer.borderWidth = 3.0
        layer.borderColor = UIColor.white.cgColor
    }
    
}
