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
    
    @State private var selectedTab: Int = ClaraTab.today.intValue
    
    @ObservedObject private var externalImportManager = ExternalImportManager.shared
    
    @ObservedObject var todoViewModel: TodoViewModel = TodoViewModel.shared
    
    @ObservedObject var categotyViewModel: CategoryViewModel = CategoryViewModel.shared
    
    var randomTodoDisplayDuration: TimeInterval = {
        if ProcessInfo.processInfo.arguments.contains("--UITestMode") {
            return 5
        }
        return 8
    }()

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                TodoListView()
                    .tabItem {
                        Label(Localization.labels.allTodosNav, systemImage: "list.bullet")
                    }
                    .tag(ClaraTab.all.intValue)
                    .accessibility(identifier: "AllTodosTab")
                TodaysListView()
                    .tabItem {
                        Label(Localization.labels.todayNav, systemImage: "calendar")
                    }.tag(ClaraTab.today.intValue)
                    .accessibility(identifier: "TodayTab")
                if categotyViewModel.hasCategories() {
                    CategoriesOverviewView()
                        .tabItem {
                            Label(Localization.labels.categoriesNav, systemImage: "line.3.horizontal.decrease")
                        }.tag(ClaraTab.categories.intValue)
                        .accessibility(identifier: "CategoriesTab")
                }
                RecurringTaskListView()
                    .tabItem {
                        Label(Localization.labels.recurringTasksNav, systemImage: "checklist")
                    }.tag(ClaraTab.recurringtasks.intValue)
                    .accessibility(identifier: "RecurringTaskTab")
            }
            .tabViewStyle(.tabBarOnly)
                        
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

enum ClaraTab {
    case all
    case today
    case recurringtasks
    case categories
    
    var intValue : Int{
        switch self {
        case .all: return 0
        case .today: return 1
        case .recurringtasks: return 2
        case .categories: return 3
        }
    }

}

