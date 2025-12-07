//
//  Views/Menu/ClaraIconSubmenu.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 27.04.25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ClaraMenuView: View {
    
    let context = DataManager.shared.context
    
    @ObservedObject var settingsViewModel: SettingsViewModel
    @ObservedObject var todoViewModel: TodoViewModel
    
    @State private var isTodaysEventsPresented = false
    
    @State private var isPriorityMatrixPresented = false
    
    @State private var isSettingsPresented = false
    
    @State private var showingShareSheet = false
    @State private var urlToShare: URL?
    
    @State private var isImporting = false
    @State private var importedFileURL: URL?
    
    @State private var isAboutViewPresented = false
    
    init(settingsViewModel: SettingsViewModel,todoViewModel: TodoViewModel) {
        self.settingsViewModel = settingsViewModel
        self.todoViewModel = todoViewModel
    }

    var body: some View {
        Menu {
            
            Button(action: {
                isTodaysEventsPresented = true
            }) {
                Label(Localization.labels.upcomingEvents, systemImage: "clock")
            }
            .accessibilityIdentifier("CalenderViewButton")
            
            Button(action: {
                if let url = URL(string: "calshow://") {
                    UIApplication.shared.open(url)
                }
            }) {
                Label(Localization.labels.openCalendar, systemImage: "calendar")
            }
            
            Button(action: {
                isPriorityMatrixPresented = true
            }) {
                Label(Localization.labels.priorityMatrix, systemImage: "arrow.clockwise")
            }
            .accessibilityIdentifier("PriorityMatrixButton")
            
            Button(action: {
                isSettingsPresented = true
            }) {
                Label(Localization.labels.properties, systemImage: "gearshape")
            }
            .accessibilityIdentifier("SettingsButton")
            
            Button(action: {
                let dateString = StyleUtils.dateTimeFormatter.string(from: Date())
                let fileName = "\(Localization.filename.exportAll)_\(dateString)"
                
                let url = ImportExportUtils.exportAllTodosToJSONFile(context: context, fileName: fileName)

                if FileManager.default.fileExists(atPath: url.path) {
                    urlToShare = url
                    showingShareSheet = true
                }
                
            }) {
                Label(Localization.labels.exportAll, systemImage: "square.and.arrow.up")
            }
            
            Button(action: {
                isImporting = true
            }) {
                Label(Localization.labels.importTodo, systemImage: "square.and.arrow.down")
            }
            
            Button (action: {
                isAboutViewPresented = true
            }) {
                Label(Localization.labels.about, systemImage: "info.circle")
            }
            
        } label: {
            Label("Menu", systemImage: "line.horizontal.3")
                .foregroundColor(Color.theme.accent)
                .accessibilityIdentifier("ClaraMenu")
        }
        .sheet(isPresented: $isPriorityMatrixPresented) {
            let todayTasks : [Todo] = todoViewModel.todayTodos.map(\.todo).filter{ !$0.isDone }
            PriorityMatrixView(
                tasks: todayTasks,
                onConfirm: { urgentTasks, importantAndUrgentTasks, nothingOfBothTasks, importantTasks in
                    isPriorityMatrixPresented = false
                    todoViewModel.reprioritizeTodos(
                        importantAndUrgentTasks: importantAndUrgentTasks,
                        urgentTasks: urgentTasks,
                        importantTasks: importantTasks,
                        nothingOfBothTasks: nothingOfBothTasks
                    )
                },
                onCancel: {
                    isPriorityMatrixPresented = false
                }
            )
        }
        .sheet(isPresented: $isSettingsPresented) {
            SettingsView(settingsViewModel: settingsViewModel)
        }
        .sheet(isPresented: $isTodaysEventsPresented) {
            if CommandLine.arguments.contains("UITestMode") {
                CalendarView(todoViewModel: todoViewModel,
                             eventProvider: FakeEventProvider())
            } else {
                CalendarView(todoViewModel: todoViewModel,
                             eventProvider: RealEventProvider())
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = urlToShare {
                ShareSheet(activityItems: [url])
            }
        }
        .sheet(isPresented: $isImporting) {
            ImportPreviewView(
                onConfirm: { todoDtos in
                    let todos = todoDtos.map { dto in
                        let entity = Todo(context: context)
                        entity.populate(from: dto, context: context)  // Deine bestehende Logik
                        return entity
                    }
                    todoViewModel.addTodos(todos)
                    isImporting = false
                },
                onCancel: {
                    isImporting = false
                }
            )
        }
        .sheet(isPresented: $isAboutViewPresented) {
            AboutView()
        }
    }
}
