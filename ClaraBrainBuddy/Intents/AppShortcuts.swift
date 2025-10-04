//
//  Intents/ClaraAppShortcuts.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 01.10.25.
//


import AppIntents

struct AppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CreateTodoIntent(),
            phrases: [
                "Write down task in \(.applicationName)",
                "Notiere Aufgabe in \(.applicationName)",
                "Add a task in \(.applicationName)",
                "Erstelle Aufgabe  in \(.applicationName)",
                "Put a task on my stack in \(.applicationName).",
                "Füge in \(.applicationName) eine Aufgabe hinzu"
            ],
            shortTitle: LocalizedStringResource( "app.intent.createtodo.title"),
            systemImageName: "checkmark.circle"
        );
        AppShortcut(
            intent: CreateTodayTodoIntent(),
            phrases: [
                "Task for today in \(.applicationName)",
                "Aufgabe für heute \(.applicationName)",
            ],
            shortTitle: LocalizedStringResource( "app.intent.createtodo.today.title2"),
            systemImageName: "clock"
        )
        AppShortcut(
            intent: CreateTodoDueByIntent(),
            phrases: [
                "Task due by in \(.applicationName)",
                "Aufgabe zu erledigen bis \(.applicationName)",
            ],
            shortTitle: LocalizedStringResource( "app.intent.createtodo.dueby.title2"),
            systemImageName: "calendar.badge.clock"
        )
    }
}
