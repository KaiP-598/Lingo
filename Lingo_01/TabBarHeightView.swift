//
//  TabBarHeightView.swift
//  Lingo_01
//
//  Created by WuKaipeng on 24/03/2017.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import UIKit

class TabBarHeightView: UITabBar {

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits =  super.sizeThatFits(size)
        sizeThatFits.height = 35
        
        return sizeThatFits
    }
}
