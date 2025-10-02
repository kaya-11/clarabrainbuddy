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
        } else if todo.isOverdue {
            return Color.theme.red
        } else if todo.isDueSoon {
            return Color.theme.accent
        }
        return Color.theme.listText
    }
    
    static func getTextColorNew(isDone: Bool, isSelectedForToday: Bool, isOverdue: Bool, isDueSoon: Bool) -> Color {
        if isDone {
            return Color.theme.green
        } else if isSelectedForToday {
            return Color.theme.blue
        } else if isOverdue {
            return Color.theme.red
        } else if isDueSoon {
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
    
    static let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter
    }()
}
