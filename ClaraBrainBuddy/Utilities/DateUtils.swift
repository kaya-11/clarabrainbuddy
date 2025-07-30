//
//  Utilities/StyleUtils2.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 28.03.25.
//

import SwiftUI

struct DateUtils {
    static func getDateThreeDaysFromNow() -> Date {
        let currentDate = Date()
        return Calendar.current.date(byAdding: .day, value: 3, to: currentDate)!
    }
    
    static func getDateSevenDaysBeforeNow() -> Date {
        let currentDate = Date()
        return Calendar.current.date(byAdding: .day, value: -7, to: currentDate)!
    }
}
