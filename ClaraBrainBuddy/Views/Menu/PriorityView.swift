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
                    priority: .urgent,
                    tasks: $urgentTasks,
                    todayTasks: $todayTasks)
                
                PriorityDropView(
                    priority: .importantAndUrgent,
                    tasks: $importantAndUrgentTasks,
                    todayTasks: $todayTasks)
            }
            HStack(spacing: 16) {
                
                PriorityDropView(
                    priority: .nothingOfBoth,
                    tasks: $nothingOfBothTasks,
                    todayTasks: $todayTasks)
                
                PriorityDropView(
                    priority: .important,
                    tasks: $importantTasks,
                    todayTasks: $todayTasks)
            }
        }
        .padding(.horizontal)
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
    @Binding var todayTasks: [Todo]

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
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
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
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.theme.secondary, lineWidth: 2)
        )
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .onDrop(
            of: [UTType.text],
            isTargeted: nil,
            perform: { providers in
                handleDrop(providers: providers)
                return true
            }
        )
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.text.identifier) { (item, error) in
                DispatchQueue.main.async {
                    if let data = item as? Data {
                        let uriString = String(decoding: data, as: UTF8.self)
                        if let index = todayTasks.firstIndex(where: { $0.objectID.uriRepresentation().absoluteString == uriString }) {
                            tasks.append(todayTasks.remove(at: index))
                        }
                    }
                }
            }
        }
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
                                explanationText: "Ziehe die Aufgaben auf eine der vier Prioritätenboxen. [...]", // Localize
                                buttonText: nil,
                                buttonAction: nil
                            )
                        }
                    }
                    .foregroundColor(Color.theme.primary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    List {
                        ForEach(todayTasks) { task in
                            TodoListEntrySimpleView(todo: task)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .onDrag {
                                    NSItemProvider(object: String(task.objectID.uriRepresentation().absoluteString) as NSString)
                                }
                        }
                    }
                    .frame(height: 260)
                    .background(Color.theme.background)
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
                    Button("Confirm", action: onConfirm) // Localize
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

