//
//  Views/Menu/Todo.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 30.11.25.
//

import SwiftUI
import UniformTypeIdentifiers
import CoreData

struct PriorityMatrixView: View {
    
    @State private var todayTasks: [Todo]
    
    @State private var urgentTasks: [Todo] = []
    @State private var importantAndUrgentTasks: [Todo] = []
    @State private var nothingOfBothTasks: [Todo] = []
    @State private var importantTasks: [Todo] = []
    
    @State private var showingInfo = false
    
    let onConfirm: (_ urgentTasks: [Todo], _ importantAndUrgentTasks: [Todo], _ nothingOfBothTasks: [Todo], _ importantTasks: [Todo]) -> Void
    let onCancel: () -> Void
    
    init(tasks: [Todo],
         onConfirm: @escaping (_ urgentTasks: [Todo], _ importantAndUrgentTasks: [Todo], _ nothingOfBothTasks: [Todo], _ importantTasks: [Todo]) -> Void,
         onCancel: @escaping () -> Void) {
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
                        Text(Localization.labels.reprioritizeTasks)
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
                                title: Localization.info.infoPriorityMatrixTitle,
                                explanationText: Localization.info.infoPriorityMatrixText, 
                                buttonText: nil,
                                buttonAction: nil
                            )
                        }
                    }
                    .foregroundColor(Color.theme.primary)
                    .padding(.leading, 24)
                    
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
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 16)
                    } else {
                        VStack {
                            Button(action: {
                                    onConfirm(urgentTasks, importantAndUrgentTasks, nothingOfBothTasks, importantTasks)
                            }) {
                                Text(Localization.labels.rearrange)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.theme.listBackground)
                                    .foregroundColor(Color.theme.accent)
                                    .cornerRadius(10)
                                    .padding(.horizontal, 24)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: 260, alignment: .leading)
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
