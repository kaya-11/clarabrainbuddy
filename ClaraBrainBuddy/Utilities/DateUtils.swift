//
//  Utilities/StyleUtils2.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 28.03.25.
//

import SwiftUI

struct DateUtils {
    static func getDateThreeDaysFromNow() -> Date {
        return getDateThreeDaysFrom(date: Date())
    }
    
    static func getDateThreeDaysFrom(date: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: 3, to: date)!
    }
    
    static func getDateSevenDaysBeforeNow() -> Date {
        return getDateSevenDaysBefore(date: Date())
    }
    
    static func getDateSevenDaysBefore(date: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: -7, to: date)!
    }
}
