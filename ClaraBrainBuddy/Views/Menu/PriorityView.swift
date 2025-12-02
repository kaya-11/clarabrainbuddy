//
//  Views/Menu/Todo.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 30.11.25.
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

enum PriorityMatrix  {
    case urgent
    case importantAndUrgent
    case nothingOfBoth
    case important

    var localizedString: String {
        
        switch self {
            case PriorityMatrix.important:
                return Localization.priority.important
            case PriorityMatrix.urgent:
                return Localization.priority.urgent
            case PriorityMatrix.importantAndUrgent:
                return Localization.priority.importantAndUrgent
            default:
                return Localization.priority.nothingOfBoth
        }
    }
}

struct PriorityDropView: View {

    let priority: PriorityMatrix
    
    @Binding var tasks: [Todo]
    
    var body: some View {
        VStack (alignment: .leading, spacing: 8) {
            Text(priority.localizedString)
                .font(Font.app.normal)
                .foregroundColor(Color.theme.accent)
                .frame(maxWidth: .infinity, alignment: .leading)

            
            if !tasks.isEmpty {
                List {
                    ForEach(tasks) { task in
                        TodoListEntrySimpleView(todo: task)
                            .font(Font.app.tiny)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                            .onDrag {
                                NSItemProvider(object: String(task.objectID.uriRepresentation().absoluteString) as NSString)
                            }
                    }
                }
                .listStyle(.plain)
                .frame(maxHeight: 130)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(8)
        .frame(width: 180, height: 180)
        .background(Color.theme.listBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.theme.secondary, lineWidth: 2)
        )
        .contentShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct PriorityView: View {
    
    @State private var todayTasks: [Todo]
    
    @State private var urgentTasks: [Todo] = []
    @State private var importantAndUrgentTasks: [Todo] = []
    @State private var nothingOfBothTasks: [Todo] = []
    @State private var importantTasks: [Todo] = []
    
    @State private var showingInfo = false
    
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    init(tasks: [Todo], onConfirm: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        self._todayTasks = State(initialValue: tasks)
    }
    
    var priorityListsEmpty : Bool {
        return urgentTasks.isEmpty
            && importantAndUrgentTasks.isEmpty
            && nothingOfBothTasks.isEmpty
            && importantTasks.isEmpty
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Aufgaben neu priorisieren") // Localize
                            .font(Font.app.listHeader)
                        Button(action: {
                            self.showingInfo.toggle()
                        }) {
                            Image(systemName: "info.circle")
                                .font(Font.app.tiny)
                        }
                        .accessibilityIdentifier("infoButton")
                        .sheet(isPresented: $showingInfo) {
                            InfoView(
                                isPresented: $showingInfo,
                                title: "Aufgaben neu priorisieren", // Localize
                                explanationText: "Wenn Du zu viele Aufgaben in Deiner Tagesplanung hast und nicht weißt mit welcher Du anfangen sollst, nutze diese Matrix, um die Aufgaben zu priorisieren, Ziehe die Aufgaben auf eine der vier Prioritätenboxen. [...]. Wenn Du auf 'Confirm' klickst, werden die Aufgaben folgendermaßen neu priorisiert: Dringende & wichtige Aufgaben landen oben in der Tagesplanung. Nur dringende Aufgaben bleiben in der Tagesplanung, werden aber nach unten verschoben. Alles was 'nur' wichtgig ist, wird aus der Tagesplanung entfernt, jedoch oben in die Übversicht aller Tasks verschoben. Alle anderen werden auch aus der Tagesplanung entfernt und unterhalb der 'wichtigen' Aufgaben platziert", // Localize
                                buttonText: nil,
                                buttonAction: nil
                            )
                        }
                    }
                    .foregroundColor(Color.theme.primary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    if !todayTasks.isEmpty {
                        VStack {
                            List {
                                ForEach(todayTasks) { task in
                                    TodoListEntrySimpleView(todo: task)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .onDrag {
                                            NSItemProvider(object: String(task.objectID.uriRepresentation().absoluteString) as NSString)
                                        }
                                }
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(width: 260, height: 260, alignment: .center)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Spacer()
                            .frame(maxWidth: .infinity, maxHeight: 260, alignment: .center)
                    }
                }
                .frame(height: 300)
                
                Spacer(minLength: 16)
                    
                PriorityBox(
                    todayTasks: $todayTasks,
                    urgentTasks: $urgentTasks,
                    importantAndUrgentTasks: $importantAndUrgentTasks,
                    nothingOfBothTasks: $nothingOfBothTasks,
                    importantTasks: $importantTasks
                )
                .frame(height: 300)
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Localization.labels.cancel, action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Neuordnen", action: onConfirm) // Localize
                        .disabled(!todayTasks.isEmpty || priorityListsEmpty)
                }
            }
            .onAppear {
                urgentTasks.removeAll()
                importantAndUrgentTasks.removeAll()
                nothingOfBothTasks.removeAll()
                importantTasks.removeAll()
            }
        }
    }
}
