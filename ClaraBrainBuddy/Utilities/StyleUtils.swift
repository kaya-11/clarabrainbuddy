//
//  Utilities/StyleUtils2.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 28.03.25.
//

import SwiftUI

struct StyleUtils {
    
    private static let LEVEL_1 = 1...3
    private static let LEVEL_2 = 4...6
    
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
    
    static func iconFontSizeForLevels(for value: Int) -> Font {
        switch value {
        case LEVEL_1:
            return .system(size: 6) // Klein
        case LEVEL_2:
            return .system(size: 8) // Mittel
        default:
            return .system(size: 10) // Groß
        }
    }
    
    static func iconFontColorForLevels(for value: Int) -> Color {
        switch value {
        case LEVEL_1:
            return Color.theme.listText
        case LEVEL_2:
            return Color.theme.accent
        default:
            return Color.theme.red
        }
    }
}
