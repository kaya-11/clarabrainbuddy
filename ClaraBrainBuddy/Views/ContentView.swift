//
//  Views/ContentView.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var context

    @State private var showRandomTodoView = true
    
    @State private var selectedTab: Int = 1
    
    @ObservedObject private var externalImportManager = ExternalImportManager.shared
    
    @ObservedObject var todoViewModel: TodoViewModel = TodoViewModel.shared
    
    var randomTodoDisplayDuration: TimeInterval = {
        if ProcessInfo.processInfo.arguments.contains("--UITestMode") {
            return 5
        }
        return 3
    }()

    var body: some View {
        ZStack {
            
            TabView(selection: $selectedTab) {
                TodoListView()
                    .tabItem {
                        Label(Localization.labels.allTodosNav, systemImage: "list.bullet")
                    }.tag(0)
                    .accessibilityIdentifier("AllTodosTab")
                TodaysListView()
                    .tabItem {
                        Label(Localization.labels.todayNav, systemImage: "calendar")
                    }.tag(1)
                    .accessibilityIdentifier("TodayTab")
                RecurringTaskListView()
                    .tabItem {
                        Label(Localization.labels.recurringTasksNav, systemImage: "checklist")
                    }.tag(2)
                    .accessibilityIdentifier("RecurringTaskTab")
            }
            
            if showRandomTodoView {
                RandomTodoView(isPresented: $showRandomTodoView)
                    .transition(.opacity)
                    .animation(.easeInOut, value: showRandomTodoView)
            }
        }
        .sheet(isPresented: $externalImportManager.showImportPreview) {
            let importedTodos = externalImportManager.importedTodos
            if !importedTodos.isEmpty {
                ImportPreviewView(
                    initialTodos: importedTodos,
                    onConfirm: { todoDtos in
                        let todos = todoDtos.map { dto in
                            let entity = Todo(context: context)
                            entity.populate(from: dto, context: context)
                            return entity
                        }
                        todoViewModel.addTodos(todos)
                        externalImportManager.cancelImport()
                    },
                    onCancel: {
                        externalImportManager.cancelImport()
                    }
                )
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + randomTodoDisplayDuration) {
                withAnimation {
                    showRandomTodoView = false
                }
            }
        }
    }

}
