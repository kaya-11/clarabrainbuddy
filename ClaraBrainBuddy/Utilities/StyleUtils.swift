//
//  Utilities/StyleUtils2.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 28.03.25.
//

import SwiftUI

struct StyleUtils {

    static func getTextColor(todo: Todo, isSelectedForToday: Bool) -> Color {
        if todo.isDone {
            return Color.theme.green
        } else if isSelectedForToday {
            return Color.theme.blue
        } else if todo.dueDate ?? Date() < getDateSevenDaysBeforeNow() {
            return Color.theme.red
        } else if todo.dueDate ?? Date() < getDateThreeDaysFromNow() {
            return Color.theme.accent
        }
        return Color.theme.listText
    }
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    static func getDateThreeDaysFromNow() -> Date {
        let currentDate = Date()
        return Calendar.current.date(byAdding: .day, value: 3, to: currentDate)!
    }
    
    static func getDateSevenDaysBeforeNow() -> Date {
        let currentDate = Date()
        return Calendar.current.date(byAdding: .day, value: -7, to: currentDate)!
    }
    
    static func getTextColorForEvent(eventIsInTodos: Bool) -> Color {
        if eventIsInTodos {
            return Color.theme.blue
        }
        return Color.theme.listText
    }
}
