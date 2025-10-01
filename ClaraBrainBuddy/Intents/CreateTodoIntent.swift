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
    var topic: String

    @MainActor
    func perform() async throws -> some IntentResult {
        if topic.isEmpty {
            return .result()
        }
        let addDays: Int = SettingsViewModel.shared.settings.daysAddedForDefaultDueDate
        let date: Date = Calendar.current.date(byAdding: .day, value: addDays, to: Date()) ?? Date()
        TodoViewModel.shared.addTodo(
            title: topic,
            details: "",
            dueDate: date,
            estimatedTime: nil
        )
        return .result()
    }
}
