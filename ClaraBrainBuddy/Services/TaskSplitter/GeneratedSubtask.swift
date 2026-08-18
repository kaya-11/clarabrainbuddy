//
//  Services/TaskSplitter/GeneratedSubtask.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 18.08.26.
//
import Foundation
import SwiftUI
import FoundationModels

@available(iOS 26.0, *)
@Generable
struct GeneratedSubtask {

    @Guide(description: "Kurzer, konkreter Titel der Teilaufgabe, beginnt mit einem Verb (max. 8 Wörter)")
    let title: String

    @Guide(description: "Optional: 1–2 Sätze mit konkreten Hinweisen zur Umsetzung")
    let details: String?

    @Guide(description: "Realistisch geschätzte Dauer in Minuten", .range(5...45))
    let estimatedTimeMinutes: Int

    @Guide(description: "Innerer Widerstand, diese Aufgabe anzufangen: 0 (fällt leicht) bis 10 (sehr schwer)", .range(0...10))
    let resistance: Int

    @Guide(description: "Wirkung auf das Energielevel: -1 (kostet Energie), 0 (neutral), 1 (gibt Energie)", .range(-1...1))
    let energyImpact: Int
}
