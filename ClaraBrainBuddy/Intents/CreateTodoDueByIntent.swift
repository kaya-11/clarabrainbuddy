//
//  Intents/CreateTodoIntent.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 30.09.25.
//

import AppIntents

struct CreateTodoDueByIntent: AppIntent {
    static var title: LocalizedStringResource = "app.intent.createtodo.dueby.title"
    static var description = IntentDescription("app.intent.createtodo.dueby.description")

    @Parameter(
        title: LocalizedStringResource("app.intent.createtodo.param.title")
    )
    var title: String
    
    @Parameter(
        title: LocalizedStringResource("app.intent.createtodo.param.duedate")
    )
    var dueDate: Date
    
    @MainActor
    func perform() async throws -> some IntentResult {
        if title.isEmpty {
            return .result()
        }
        
        let isDueToday = Calendar.current.isDate(dueDate, inSameDayAs: Date())
        
        let defaultCategory = CategoryViewModel.shared.getDefaultCategory()
        
        if isDueToday {
            TodoViewModel.shared.addNewTodoForToday(
                title: title,
                details: "",
                estimatedTime: nil,
                category: defaultCategory,
                recurringTask: nil
            )
        } else {
            TodoViewModel.shared.addTodo(
                title: title,
                details: "",
                dueDate: dueDate,
                estimatedTime: nil,
                category: defaultCategory
            )
        }
        
        return .result()
    }
}
