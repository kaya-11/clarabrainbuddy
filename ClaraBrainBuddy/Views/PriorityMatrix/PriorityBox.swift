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
                )
                .onDrop(of: [UTType.text], isTargeted: nil) { providers in
                    handleDrop(providers: providers, target: $importantAndUrgentTasks)
                }
                
                PriorityDropView(
                    priority: .urgent,
                    tasks: $urgentTasks
                )
                .onDrop(of: [UTType.text], isTargeted: nil) { providers in
                    handleDrop(providers: providers, target: $urgentTasks)
                }
            }
            .padding(.horizontal, 16)
            
            HStack(spacing: 16) {
                
                PriorityDropView(
                    priority: .important,
                    tasks: $importantTasks
                )
                .onDrop(of: [UTType.text], isTargeted: nil) { providers in
                    handleDrop(providers: providers, target: $importantTasks)
                }

                PriorityDropView(
                    priority: .nothingOfBoth,
                    tasks: $nothingOfBothTasks
                )
                .onDrop(of: [UTType.text], isTargeted: nil) { providers in
                    handleDrop(providers: providers, target: $nothingOfBothTasks)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.horizontal)
    }
    
    private func handleDrop(providers: [NSItemProvider], target: Binding<[Todo]>) -> Bool {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.text.identifier) { (item, error) in
                DispatchQueue.main.async {
                    if let data = item as? Data {
                        let uriString = String(decoding: data, as: UTF8.self)
                        moveTodo(withURI: uriString, to: target)
                    }
                }
            }
        }
        return true
    }

    private func moveTodo(withURI uriString: String, to target: Binding<[Todo]>) {
        // 1. Suche in todayTasks (Ursprungsliste)
        if let index = todayTasks.firstIndex(where: { $0.objectID.uriRepresentation().absoluteString == uriString }) {
            target.wrappedValue.append(todayTasks.remove(at: index))
            return
        }

        // 2. Suche in den DropViews
        if let index = urgentTasks.firstIndex(where: { $0.objectID.uriRepresentation().absoluteString == uriString }) {
            target.wrappedValue.append(urgentTasks.remove(at: index))
        } else if let index = importantAndUrgentTasks.firstIndex(where: { $0.objectID.uriRepresentation().absoluteString == uriString }) {
            target.wrappedValue.append(importantAndUrgentTasks.remove(at: index))
        } else if let index = nothingOfBothTasks.firstIndex(where: { $0.objectID.uriRepresentation().absoluteString == uriString }) {
            target.wrappedValue.append(nothingOfBothTasks.remove(at: index))
        } else if let index = importantTasks.firstIndex(where: { $0.objectID.uriRepresentation().absoluteString == uriString }) {
            target.wrappedValue.append(importantTasks.remove(at: index))
        }
    }
}
