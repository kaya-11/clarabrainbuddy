//
//  Intents/CreateTodoIntent.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 30.09.25.
//

import AppIntents

struct CreateTodayTodoIntent: AppIntent {
    static var title: LocalizedStringResource = "app.intent.createtodo.today.title"
    static var description = IntentDescription("app.intent.createtodo.today.description")

    @Parameter(
        title: LocalizedStringResource("app.intent.createtodo.param.title")
    )
    var title: String

    @MainActor
    func perform() async throws -> some IntentResult {
        if title.isEmpty {
            return .result()
        }
        TodoViewModel.shared.addNewTodoForToday(
            title: title,
            details: "",
            estimatedTime: nil,
            recurringTask: nil
        )
        return .result()
    }
}
