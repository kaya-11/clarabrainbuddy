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
            if truncatedTitle.count > TodoViewModel.TITLE_MAX_LENGTH {
                truncatedTitle = String(truncatedTitle.prefix(TodoViewModel.TITLE_MAX_LENGTH))
            }
            
            var cleanDetails: String? = nil
            if let details = todo.details?.trimmingCharacters(in: .whitespacesAndNewlines), !details.isEmpty {
                cleanDetails = String(details.prefix(TodoViewModel.DETAILS_MAX_LENGTH))
            }
            
            var cleanCategory: CategoryDto? = nil
            if let category = todo.category {
                var cleanCategoryName = category.name.trimmingCharacters(in: .whitespacesAndNewlines)
                cleanCategoryName = String(cleanCategoryName.prefix(CategoryViewModel.MAX_LENGTH_NAME))
                cleanCategory = CategoryDto(name: cleanCategoryName)
            }
            
            return TodoDto(
                title: truncatedTitle,
                details: cleanDetails,
                dueDate: todo.dueDate,
                estimatedTime: todo.estimatedTime.map { Int64($0.clamped(to: 0...1440)) } ?? nil,
                energyImpact: todo.energyImpact.map { Int64($0.clamped(to: -1...1)) } ?? 0,
                selectedForToday: false,
                isDone: todo.isDone,
                resistance: Int64(todo.resistance.clamped(to: 0...19)),
                createdAt: todo.createdAt,
                updatedAt: todo.updatedAt,
                category: cleanCategory
            )
        }
    }
}
