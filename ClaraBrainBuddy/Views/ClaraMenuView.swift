//
//  Views/ClaraIconSubmenu.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 27.04.25.
//

import SwiftUI

struct ClaraMenuView: View {
    
    @ObservedObject var settingsViewModel: SettingsViewModel
    @ObservedObject var todoViewModel: TodoViewModel
    
    @State private var isSettingsPresented = false
    @State private var isTodaysEventsPresented = false
    
    @State private var showingShareSheet = false
    @State private var urlToShare: URL?

    var body: some View {
        Menu {
            
            Button(action: {
                isTodaysEventsPresented = true
            }) {
                Text("Today's Events")
            }
            
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

        
        } label: {
            Image(systemName: "line.horizontal.3")
                .foregroundColor(Color.theme.accent)
        }
        .fullScreenCover(isPresented: $isSettingsPresented) {
            SettingsView(settingsViewModel: settingsViewModel)
        }
        .fullScreenCover(isPresented: $isTodaysEventsPresented) {
            CalendarView(todoViewModel: todoViewModel)
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = urlToShare {
                ShareSheet(activityItems: [url])
            }
        }
    }
}
