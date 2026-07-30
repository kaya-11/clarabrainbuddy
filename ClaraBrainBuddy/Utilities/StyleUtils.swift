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
            return Color.theme.yellow
        }
        return Color.theme.surfaceGlassTextColor
    }

    static func getTextColorForToday(todo: Todo, isSelectedForToday: Bool) -> Color {
        if todo.isDone {
            return Color.theme.green
        } else if isSelectedForToday {
            return Color.theme.blue
        } else if todo.isOverdue {
            return Color.theme.red
        }
        return Color.theme.surfaceGlassTextColor
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
