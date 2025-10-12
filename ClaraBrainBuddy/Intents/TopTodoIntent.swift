//
//  ShowTodayTodoIntent.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 12.10.25.
//

import SwiftUI
import AppIntents

struct TopTodoIntent: AppIntent {
    static var title: LocalizedStringResource = "app.intent.toptodo.title"
    static var description = IntentDescription("app.intent.toptodo.description")
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let todayTodos = TodoViewModel.shared.todayTodos.filter { !$0.todo.isDone }
        
        guard let firstTodo = todayTodos.first else {
            return .result(value: Localization.labels.noTodosToday)
        }
        
        var details: [String] = []
        
        // Title
        details.append("\(firstTodo.todo.title)")
        
        
        // Details
        let todoDetails = (firstTodo.todo.details ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !todoDetails.isEmpty {
            
            let truncatedDetails = todoDetails.count > 100
                ? String(todoDetails.prefix(100)) + "…"
                : todoDetails
            
            details.append("\(Localization.labels.details): \(truncatedDetails)")
        }
        
        // Due Date
        let formattedDate = StyleUtils.dateFormatter.string(from: firstTodo.todo.dueDate)
        details.append("\(Localization.labels.due): \(formattedDate)")
        
        
        // Estimated Time
        if let estimatedTime = firstTodo.todo.estimatedTime {
            details.append("\(Localization.labels.estimatedTime): \(estimatedTime) \(Localization.labels.estimatedTimeUnit)")
        }
        
        let resultText = details.joined(separator: "\n")
        return .result(value: resultText)
    }
}
