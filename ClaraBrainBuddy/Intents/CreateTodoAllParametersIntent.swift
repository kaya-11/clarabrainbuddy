//
//  Intents/CreateTodoIntent.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 30.09.25.
//

import AppIntents

struct CreateTodoAllParamsIntent: AppIntent {
    static var title: LocalizedStringResource = "app.intent.createtodo.allparams.title"
    static var description = IntentDescription("app.intent.createtodo.allparams.description")

    @Parameter(
        title: LocalizedStringResource("app.intent.createtodo.param.title")
    )
    var title: String
    
    @Parameter(
        title: LocalizedStringResource("app.intent.createtodo.param.description")
    )
    var description: String?

    @Parameter(
        title: LocalizedStringResource("app.intent.createtodo.param.duedate")
    )
    var dueDate: Date?

    @Parameter(
        title: LocalizedStringResource("app.intent.createtodo.param.estimatedtime")
    )
    var estimatedTime: Int?
    
    @Parameter(
        title: LocalizedStringResource("app.intent.createtodo.param.category")
    )
    var category: String?
    
    @MainActor
    func perform() async throws -> some IntentResult {
        if title.isEmpty {
            return .result()
        }
        
        let intentDueDate = dueDate ?? Date()
        
        let isDueToday = Calendar.current.isDate(intentDueDate, inSameDayAs: Date())
        
        var intentEstimatedTime : Int64? = nil
        if estimatedTime != nil {
            intentEstimatedTime = Int64(estimatedTime ?? 0)
        }
        
        var intentCategory : Category? = CategoryViewModel.shared.getCategoryByName(name: category)
        if intentCategory == nil {
            intentCategory = CategoryViewModel.shared.getDefaultCategory()
        }
        
        if isDueToday {
            TodoViewModel.shared.addNewTodoForToday(
                title: title,
                details: description ?? "",
                estimatedTime: intentEstimatedTime,
                category: intentCategory,
                recurringTask: nil
            )
        } else {
            TodoViewModel.shared.addTodo(
                title: title,
                details: description ?? "",
                dueDate: intentDueDate,
                estimatedTime: intentEstimatedTime,
                category: intentCategory
            )
        }
        
        return .result()
    }
}
