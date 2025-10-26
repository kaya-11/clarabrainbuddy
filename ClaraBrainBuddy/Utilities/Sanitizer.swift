//
//  Utilities/Sanitizer.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 01.08.25.
//

import SwiftUI


struct Sanitizer {
    
    static func sanitizeTodos(_ todos: [TodoDto]) -> [TodoDto] {
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
            
            return TodoDto(
                title: truncatedTitle,
                details: cleanDetails,
                dueDate: todo.dueDate,
                estimatedTime: todo.estimatedTime.map { Int64($0.clamped(to: 0...1440)) } ?? nil,
                energyImpact: todo.energyImpact.map { Int64($0.clamped(to: -1...1)) } ?? 0,
                selectedForToday: false,
                isDone: todo.isDone,
                resistance: Int64(todo.resistance.clamped(to: 0...11)),
                createdAt: todo.createdAt,
                updatedAt: todo.updatedAt
            )
        }
    }
}
