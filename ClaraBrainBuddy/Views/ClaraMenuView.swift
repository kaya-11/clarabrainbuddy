//
//  Views/ClaraIconSubmenu.swift
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
    
    @State private var isSettingsPresented = false
    @State private var isTodaysEventsPresented = false
    
    @State private var showingShareSheet = false
    @State private var urlToShare: URL?
    
    @State private var isImporting = false
    @State private var importedFileURL: URL?
    
    init(settingsViewModel: SettingsViewModel,todoViewModel: TodoViewModel) {
        self.settingsViewModel = settingsViewModel
        self.todoViewModel = todoViewModel
    }

    var body: some View {
        Menu {
            
            Button(action: {
                isTodaysEventsPresented = true
            }) {
                Text("Today's Event")
            }
            .accessibilityIdentifier("CalenderViewButton")
            
            Button(action: {
                if let url = URL(string: "calshow://") {
                    UIApplication.shared.open(url)
                }
            }) {
                Text(Localization.labels.openCalendar)
            }
            
            Button(action: {
                isSettingsPresented = true
            }) {
                Text(Localization.labels.properties)
            }
            .accessibilityIdentifier("SettingsButton")
            
            Button(action: {
                let dateString = StyleUtils.dateTimeFormatter.string(from: Date())
                let fileName = "Clara_All_Todos_\(dateString).json"
                
                let url = ImportExportUtils.exportAllTodosToJSONFile(context: context, fileName: fileName)

                if FileManager.default.fileExists(atPath: url.path) {
                    urlToShare = url
                    showingShareSheet = true
                }
                
            }) {
                Text(Localization.labels.exportAll)
            }
            
            Button(action: {
                isImporting = true
            }) {
                Text("Import Todos")
            }

        
        } label: {
            Label("Menu", systemImage: "line.horizontal.3")
                .foregroundColor(Color.theme.accent)
                .accessibilityIdentifier("ClaraMenu")
        }
        .fullScreenCover(isPresented: $isSettingsPresented) {
            SettingsView(settingsViewModel: settingsViewModel)
        }
        .fullScreenCover(isPresented: $isTodaysEventsPresented) {
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
    }
}
