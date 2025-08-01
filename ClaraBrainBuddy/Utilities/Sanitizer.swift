//
//  Utilities/Sanitizer.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 01.08.25.
//

import SwiftUI


struct Sanitizer {
    
    static func sanitizeTodos(_ todos: [Todo]) -> [Todo] {
        return todos.compactMap { todo in
            // Basic validation
            let cleanTitle = todo.title.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !cleanTitle.isEmpty else {
                return nil // Reject empty titles
            }
            
            // Sanitize strings
            var truncatedTitle = cleanTitle
            if truncatedTitle.count > 100 {
                truncatedTitle = String(truncatedTitle.prefix(100))
            }
            
            var cleanDetails: String? = nil
            if let details = todo.details?.trimmingCharacters(in: .whitespacesAndNewlines), !details.isEmpty {
                cleanDetails = String(details.prefix(500))
            }
            
            return Todo(
                id: UUID(), // Always regenerate UUID
                title: truncatedTitle,
                details: cleanDetails,
                dueDate: todo.dueDate,
                estimatedTime: todo.estimatedTime?.clamped(to: 0...1440),
                isSelectedForToday: false,
                isDone: todo.isDone,
                resistance: todo.resistance?.clamped(to: 0...10) ?? 0
            )
        }
    }
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
