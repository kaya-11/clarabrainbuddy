//
//  Views/PriorityMatrixPriorityBox.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 05.12.25.
//


import SwiftUI
import UniformTypeIdentifiers
import CoreData

struct PriorityBox: View {
    
    @Binding var todayTasks: [Todo]
    
    @Binding var urgentTasks: [Todo]
    @Binding var importantAndUrgentTasks: [Todo]
    @Binding var nothingOfBothTasks: [Todo]
    @Binding var importantTasks: [Todo]

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                PriorityDropView(
                    priority: .importantAndUrgent,
                    tasks: $importantAndUrgentTasks
                ) { uri in
                    moveTodo(withURI: uri, to: $importantAndUrgentTasks)
                }
                .accessibilityIdentifier("ImportantAndUrgentView")
                
                PriorityDropView(
                    priority: .urgent,
                    tasks: $urgentTasks
                ) { uri in
                    moveTodo(withURI: uri, to: $urgentTasks)
                }
                .accessibilityIdentifier("UrgentView")
            }
            .padding(.horizontal, 16)
            
            HStack(spacing: 16) {
                
                PriorityDropView(
                    priority: .important,
                    tasks: $importantTasks
                ) { uri in
                    moveTodo(withURI: uri, to: $importantTasks)
                }
                .accessibilityIdentifier("ImportanttView")

                PriorityDropView(
                    priority: .nothingOfBoth,
                    tasks: $nothingOfBothTasks
                ){ uri in
                    moveTodo(withURI: uri, to: $nothingOfBothTasks)
                }
                .accessibilityIdentifier("NothingOfBoth")
            }
            .padding(.horizontal, 16)
        }
        .background(Color.clear)
        .padding(.horizontal)
    }
    
    private func moveTodo(withURI uriString: String, to target: Binding<[Todo]>) {

        // Nicht verschieben, wenn das Todo schon in der Ziel-Liste liegt
        if target.wrappedValue.contains(where: { $0.objectID.uriRepresentation().absoluteString == uriString }) {
            return
        }

        let allSources: [Binding<[Todo]>] = [
            $todayTasks, $urgentTasks, $importantAndUrgentTasks,
            $nothingOfBothTasks, $importantTasks
        ]

        for source in allSources {
            if let index = source.wrappedValue.firstIndex(where: {
                $0.objectID.uriRepresentation().absoluteString == uriString
            }) {
                let todo = source.wrappedValue.remove(at: index)
                target.wrappedValue.append(todo)
                return
            }
        }
    }
}
