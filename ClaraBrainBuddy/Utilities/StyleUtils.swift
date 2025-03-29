//
//  Utilities/StyleUtils2.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 28.03.25.
//

import SwiftUI

struct StyleUtils {
    static func getTextColor(todo: Todo, isSelectedForToday: Bool) -> Color {
        let currentDate = Date()
        let threeDaysFromNow = Calendar.current.date(byAdding: .day, value: 3, to: currentDate)!

        if todo.isDone {
            return Color.theme.green
        } else if isSelectedForToday {
            return Color.theme.blue
        } else if todo.dueDate ?? Date() < threeDaysFromNow {
            return Color.theme.accent
        }
        return Color.theme.listText
    }
}
