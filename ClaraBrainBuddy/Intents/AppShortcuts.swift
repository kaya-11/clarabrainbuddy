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
                "Notiere Aufgabe in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource( "app.intent.createtodo.title"),
            systemImageName: "plus.circle"
        );
        AppShortcut(
            intent: CreateTodayTodoIntent(),
            phrases: [
                "Add a task to \(.applicationName) for today",
                "Erstelle Task in \(.applicationName) for today",
                "I have to do today.",
                "Ich muss heute noch erledigen.",
                "Put a task on my stack in \(.applicationName).",
                "Füge in \(.applicationName) eine mAufgabe hinzu"
            ],
            shortTitle: LocalizedStringResource( "app.intent.createtodaytodo.title"),
            systemImageName: "calendar"
        )
    }
}
