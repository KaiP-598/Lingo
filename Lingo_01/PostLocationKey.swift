//
//  PostLocationKey.swift
//  Lingo_01
//
//  Created by WuKaipeng on 29/03/2017.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import Foundation
import UIKit

class PostLocationDateKey{
    
    static let manager = PostLocationDateKey()
    
    private var _dateKeys = [String]()
    
    var dateKeys: [String] {
        return _dateKeys
    }
    
    func getInitialDate()-> Date{
        var dateComponents = DateComponents()
        dateComponents.year = 2017
        dateComponents.month = 1
        dateComponents.day = 1
        let userCalendar = Calendar.current
        let initialDay = userCalendar.date(from: dateComponents)
        return initialDay!
    }
    
    func getCurrentDateKey() -> String{
        let initDate = getInitialDate()
        let currentDate = Date()
        let numDays = currentDate.interval(ofComponent: .day, fromDate: initDate)
        print ("numdays: \(numDays)")
        return String(numDays)
    }
}

extension Date{
    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {
        
        let currentCalendar = Calendar.current
        
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }
        
        return end - start
    }
}
