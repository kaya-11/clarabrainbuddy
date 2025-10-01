//
//  Intents/CreateTodoIntent.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 30.09.25.
//

import AppIntents

struct CreateTodayTodoIntent: AppIntent {
    static var title: LocalizedStringResource = "app.intent.createtodaytodo.title"
    static var description = IntentDescription("app.intent.createtodaytodo.description")

    @Parameter(
        title: LocalizedStringResource("app.intent.createtodaytodo.param.title")
    )
    var topic: String

    @MainActor
    func perform() async throws -> some IntentResult {
        if topic.isEmpty {
            return .result()
        }
        TodoViewModel.shared.addNewTodoForToday(
            title: topic,
            details: "",
            estimatedTime: nil,
            recurringTask: nil
        )
        return .result()
    }
}
