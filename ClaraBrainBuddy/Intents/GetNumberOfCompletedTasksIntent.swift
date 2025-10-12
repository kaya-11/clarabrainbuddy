//
//  GetRandomNumberIntent.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 12.10.25.
//


import AppIntents

struct GetNumberOfCompletedTasksIntent: AppIntent {
    static var title: LocalizedStringResource = "app.intent.numberofcompletedtasks.title"
    static var description = IntentDescription("app.intent.numberofcompletedtasks.description")
    
    func perform() async throws -> some IntentResult & ReturnsValue<Int> {
        let (count, _) = TodoViewModel.shared.calculateCompletedTodaysTodos()
        
        return .result(value: count)
    }
}
