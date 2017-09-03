//
//  CircieView.swift
//  Lingo_01
//
//  Created by WuKaipeng on 24/03/2017.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import UIKit

class CircieView: UIImageView {
    
    override func layoutSubviews() {
        layer.cornerRadius = self.frame.width / 2
        clipsToBounds = true
    }

}
