//
//  timeStampHelper.swift
//  Lingo_01
//
//  Created by WuKaipeng on 9/04/2017.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import Foundation

class timeStampHelper{
    
    static let timeManager = timeStampHelper()
    
    func getTime(timeStamp: Int)-> String{
        let currentTime = Int(Date().timeIntervalSince1970)
        let secDifference = currentTime - timeStamp
        let minDifference = Int(secDifference / 60)
        let hourDifference = Int(secDifference / 3600)
        
        if minDifference < 60 {
            return ("\(minDifference) MIN AGO")
        } else if (hourDifference < 24){
            return ("\(hourDifference) HOURS AGO")
        } else {
            return ("1 DAY AGO")
        }
    }
    
}
