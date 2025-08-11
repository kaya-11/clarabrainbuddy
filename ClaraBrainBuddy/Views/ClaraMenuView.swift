//
//  Views/ClaraIconSubmenu.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 27.04.25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ClaraMenuView: View {
    
    @ObservedObject var settingsViewModel: SettingsViewModel
    @ObservedObject var todoViewModel: TodoViewModel
    
    @State private var isSettingsPresented = false
    @State private var isTodaysEventsPresented = false
    
    @State private var showingShareSheet = false
    @State private var urlToShare: URL?
    
    @State private var isImporting = false
    @State private var importedFileURL: URL?
    
    @State private var isPreviewingImport = false
    @State private var importedTodos: [Todo] = []
    
    @State private var showingAlert = false

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
                
                let todos = todoViewModel.allTodos
                
                let url = ImportExportUtils.exportTodosToJSONFile(todos: todos, fileName: fileName)

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
        .sheet(isPresented: $isPreviewingImport) {
            ImportPreviewView(
                todos: importedTodos,
                onConfirm: {
                    todoViewModel.addTodos(importedTodos)
                    importedTodos = []
                    isPreviewingImport = false
                },
                onCancel: {
                    importedTodos = []
                    isPreviewingImport = false
                }
            )
        }
        .fileImporter(isPresented: $isImporting, allowedContentTypes: [.json], allowsMultipleSelection: false) { result in
            switch result {
            case .success(let urls):
                guard let selectedFileURL = urls.first else { return }
                
                if selectedFileURL.startAccessingSecurityScopedResource() {
                    defer { selectedFileURL.stopAccessingSecurityScopedResource() }
                    
                    let todos = ImportExportUtils.importTodosFromJSONFile(fileURL: selectedFileURL)
                    if !todos.isEmpty {
                        importedTodos = todos
                        isPreviewingImport = true
                    } else {
                        print("No valid todos found in the file.")
                        showingAlert = true
                    }
                } else {
                    showingAlert = true
                    print("Failed to access the security-scoped resource.")
                }
            case .failure(let error):
                showingAlert = true
                print("Error importing file: \(error.localizedDescription)")
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(Localization.labels.importing), message: Text(Localization.messages.noValidTodos))
        }
    }
}
