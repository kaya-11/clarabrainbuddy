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
            VStack(spacing: 16) {
                if !todayTasks.isEmpty {
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(todayTasks) { task in
                                TodoListEntrySimpleView(todo: task)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(Rectangle())
                                    .onDrag {
                                        NSItemProvider(object: task.objectID.uriRepresentation().absoluteString as NSString)
                                    } preview: {
                                        Text(task.title.count > 10 ? String(task.title.prefix(10) + "...") : task.title)
                                            .font(Font.app.tiny)
                                            .lineLimit(1)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .accessibilityIdentifier("PriorityTodoContainer")
                    .frame(maxWidth: 280)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, 24 )
                

                } else {
                    
                    VStack {
                        Button {
                            onConfirm(urgentTasks, importantAndUrgentTasks, nothingOfBothTasks, importantTasks)
                        } label: {
                            Label(Localization.labels.rearrange, systemImage: "none")
                                .frame(maxWidth: .infinity)
                                .bold()
                                .accessibilityIdentifier("RearrangeButton")
                        }
                        .padding(.horizontal, 24)
                        .buttonStyle()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, 24 )
                    
                    Spacer(minLength: 0)
                }
                    
                
                PriorityBox(
                    todayTasks: $todayTasks,
                    urgentTasks: $urgentTasks,
                    importantAndUrgentTasks: $importantAndUrgentTasks,
                    nothingOfBothTasks: $nothingOfBothTasks,
                    importantTasks: $importantTasks
                )
                .padding(.bottom, 16)
                
            }
            .appTheme()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Localization.labels.cancel, action: onCancel)
                }
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text(Localization.labels.reprioritizeTasks)
                            .font(Font.app.header)
                        Button(action: {
                            self.showingInfo.toggle()
                        }) {
                            Image(systemName: "info.circle")
                                .font(Font.app.tiny)
                        }
                        .accessibilityIdentifier("infoButtonPriority")
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
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                urgentTasks.removeAll()
                importantAndUrgentTasks.removeAll()
                nothingOfBothTasks.removeAll()
                importantTasks.removeAll()
            }
        }
    }
}
