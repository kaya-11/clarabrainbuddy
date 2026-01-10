//
//  Intents/CreateTodoIntent.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 30.09.25.
//

import AppIntents

struct CreateTodoIntent: AppIntent {
    static var title: LocalizedStringResource = "app.intent.createtodo.title"
    static var description = IntentDescription("app.intent.createtodo.description")

    @Parameter(
        title: LocalizedStringResource("app.intent.createtodo.param.title")
    )
    var title: String
    
    @MainActor
    func perform() async throws -> some IntentResult {
        if title.isEmpty {
            return .result()
        }
        
        let addDays = SettingsViewModel.shared.settings.daysAddedForDefaultDueDate
        
        let defaultCategory = CategoryViewModel.shared.getDefaultCategory()
        
        TodoViewModel.shared.addTodo(
            title: title,
            details: "",
            dueDate: Calendar.current.date(byAdding: .day, value: addDays, to: Date()) ?? Date(),
            estimatedTime: nil,
            category: defaultCategory
        )
        
        return .result()
    }
}
