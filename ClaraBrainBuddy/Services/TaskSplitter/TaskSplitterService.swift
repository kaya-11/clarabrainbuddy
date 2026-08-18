//
//  Services/TaskSplitter/TaskSplitterService.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 29.07.26.
//

import Foundation
import SwiftUI
import FoundationModels

@available(iOS 26.0, *)
@MainActor
final class TaskSplitterService {

    static var isAvailable: Bool {
        SystemLanguageModel.default.availability == .available
    }
    
    private static func instructions(for domain: TaskDomain, task: String) -> String {
        """
        Du bist ein einfühlsamer Assistent in einer Todo-App für neurodivergente \
        Menschen. Sprich die Person mit Du an.
        
        Deine Aufgabe: Zerlege ausschließlich die folgende Aufgabe in kleine, \
        konkrete, nacheinander ausführbare Teilaufgaben:
        
        AUFGABE: "\(task)" (Bereich: \(domain.rawValue)) 
                
        Jede Teilaufgabe soll so klein sein, dass der Einstieg leichfällt. \
        (meist 5 bis 30 Minuten). Beginne jeden Titel mit einem Verb. \
        Die erste Teilaufgabe soll besonders niedrigschwellig sein, damit der \
        Start gelingt.
        
        Erzeuge 5 bis 8 Teulaufgaben. Wenn ein Schritt länger als 45 Minuten dauern \
        würde, teile ihn auf. 
        
        Das folgende Beispiel zeigt eine ANDERE Aufgabe. Es dient nur als Muster \
        für Granularität, Stil und realistische Werte. Übernimm daraus keine \
        Titel oder Inhalt.

        Hier ist ein Beispiel wie eine Liste von Aufgaben aus dem Bereich \(domain.rawValue) aussehen könnte:
        \(domain.fewShotExample)
        
        Schätze Dauer, inneren Widerstand und Energie-Wirkung realistisch ein, \
        so wie im Beispiel. Alle Teilaufgaben müssen sich konkret auf \
        "\(task)" beziehen.
        
        Antworte in der Sprache der Eingabe.
        """
    }
    
    func split(
        _ mainTask: String,
        category: CategoryDto? = nil
    ) async throws -> [TodoDto] {
        let domain = await detectDomain(for: mainTask)

        let session = LanguageModelSession(
            instructions: Self.instructions(for: domain, task: mainTask)
        )

        let response = try await session.respond(
            to: """
            Zerlege jetzt Aufgabe "\(mainTask)" in Teilaufgaben. \
            Nicht die Beispielaufgabe - nur "\(mainTask)".
            """,
            generating: SubtaskList.self,
            options: GenerationOptions(temperature: 0.3)
        )

        return response.content.subtasks.map { $0.toDto(category: category) }
    }

    @Generable
    struct DomainGuess {
        @Guide(description: "Passender Bereich", .anyOf(TaskDomain.allCases.map(\.rawValue)))
        let domain: String
    }

    private func detectDomain(for mainTask: String) async -> TaskDomain {
        let session = LanguageModelSession(
            instructions: "Ordne die Aufgabe genau einem Bereich zu."
        )
        let guess = try? await session.respond(
            to: "Aufgabe: '\(mainTask)'",
            generating: DomainGuess.self,
            options: GenerationOptions(temperature: 0.0)
        )
        return TaskDomain(rawValue: guess?.content.domain ?? "") ?? .sonstiges
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

