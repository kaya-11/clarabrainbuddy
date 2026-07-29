//
//  GeneratedSubtask.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 29.07.26.
//

// TODO: Texte in Localize schieben

import Foundation
import SwiftUI
import FoundationModels

@available(iOS 26.0, *)
@Generable
struct GeneratedSubtask {

    @Guide(description: "Kurzer, prägnanter Titel der Teilaufgabe (max. 8 Wörter)")
    let title: String

    @Guide(description: "Optional: 1–2 Sätze mit konkreten Hinweisen zur Umsetzung")
    let details: String?

    @Guide(description: "Realistisch geschätzte Dauer in Minuten (5 bis 1440)")
    let estimatedTimeMinutes: Int

    @Guide(description: "Innerer Widerstand, diese Aufgabe anzufangen: 0 (fällt leicht) bis 10 (sehr schwer)")
    let resistance: Int

    @Guide(description: "Wirkung auf das Energielevel: -1 (kostet Energie), 0 (neutral), 1 (gibt Energie)")
    let energyImpact: Int
}

@available(iOS 26.0, *)
@MainActor
final class TaskSplitterService {

    static var isAvailable: Bool {
        SystemLanguageModel.default.availability == .available
    }

    private let session = LanguageModelSession(
        instructions: """
        Du bist ein einfühlsamer Assistent in einer Todo-App für neurodivergente \
        Menschen. Verwende Du als Ansprache. Zerlege die gegebene Aufgabe in 3 bis maximal 12 kleine, konkrete, \
        nacheinander ausführbare Teilaufgaben. Jede Teilaufgabe soll so klein \
        sein, dass der Einstieg leichtfällt, also ungefähr 10 bis 30 Minuten dauern. \
        Die Aufgaben sollen nicht zu grob sein. 
        Hier ein Beispiel: Die Aufgabe 'Steuererklärung' wird zerlegt in: \
        'Programm installieren',  'Dokumente sortieren', 'Alte Daten vom Vorjahr übernehmen', \
        'Daten eingeben', 'Daten prüfen', ’Steuererklärung abgeben'. \
        \
        Schätze Dauer, Fälligkeitsdatum, inneren Widerstand und Energie-Wirkung realistisch ein. \
        Erstelle lieber eine Aufgabe mehr als eine zu wenig \
        Antworte in der Sprache der Eingabe.
        """
    )

    func prewarm() {
        session.prewarm()
    }

    func split(
        _ mainTask: String,
        category: CategoryDto? = nil
    ) async throws -> [TodoDto] {
        let response = try await session.respond(
            to: "Zerlege die folgende Aufgabe in Teilaufgaben: '\(mainTask)'",
            generating: [GeneratedSubtask].self
        )
        return response.content.map { $0.toDto(category: category) }
    }
}

@available(iOS 26.0, *)
extension GeneratedSubtask {

    func toDto(category: CategoryDto?) -> TodoDto {
        TodoDto(
            title: title,
            details: details,
            dueDate: Date(),
            estimatedTime: Int64(min(max(estimatedTimeMinutes, 0), 1440)),
            energyImpact: Int64(min(max(energyImpact, -1), 1)),
            selectedForToday: false,
            isDone: false,
            resistance: Int64(min(max(resistance, 0), 10)),
            category: category
        )
    }
}
