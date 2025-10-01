//
//  Views/ImportPreviewView.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 01.08.25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ImportPreviewView: View {
    
    let onConfirm: ([TodoDto]) -> Void
    let onCancel: () -> Void

    @Environment(\.dismiss) private var dismiss
    
    @State private var showFileImporter = false
    @State private var importedTodos: [TodoDto] = []
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Group {
                if importedTodos.isEmpty {
                    VStack {
                        Text(Localization.messages.selectFileToImport)
                            .foregroundColor(Color.theme.listText)
                            .padding()
                        ProgressView()
                    }
                } else {
                    List(importedTodos) { todo in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(todo.title)
                                .font(.headline)
                            if let details = todo.details {
                                Text(details)
                            }
                            Text("\(Localization.labels.dueDate): \(todo.dueDate, formatter: StyleUtils.dateFormatter)")
                                .font(Font.app.tiny)
                                .foregroundColor(Color.theme.listText)
                            if let estimatedTime = todo.estimatedTime {
                                Text("\(Localization.labels.estimatedTime): \(estimatedTime) \(Localization.labels.estimatedTimeUnit)")
                                    .font(Font.app.tiny)
                                    .foregroundColor(Color.theme.listText)
                            }
                        }
                        .foregroundColor(Color.theme.listText)
                        .listRowBackground(Color.theme.listBackground)
                        .font(Font.app.listItem)
                        .padding(.vertical, 4)
                    }
                    .backgroundStyle()
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(Localization.labels.previewImport)
                        .foregroundColor(Color.theme.primary)
                        .font(Font.app.title)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(Localization.labels.cancel, action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    if !importedTodos.isEmpty {
                        Button(Localization.labels.importing, action: {
                            onConfirm(importedTodos)
                        })
                    }
                }
            }
            .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.json], allowsMultipleSelection: false) { result in
                switch result {
                case .success(let urls):
                    guard let selectedFileURL = urls.first else {
                        onCancel()
                        return
                    }
                    if selectedFileURL.startAccessingSecurityScopedResource() {
                        defer { selectedFileURL.stopAccessingSecurityScopedResource() }
                        do {
                            importedTodos = try ImportExportUtils.importTodosFromJSONFile(fileURL: selectedFileURL)
                        } catch {
                            print("Error importing todos: \(error.localizedDescription)")
                            alertMessage = error.localizedDescription
                            showingAlert = true
                        }
                    } else {
                        alertMessage = Localization.errors.fileNotFound
                        showingAlert = true
                    }
                case .failure(let error):
                    print("FileImporter error: \(error.localizedDescription)")
                    alertMessage = error.localizedDescription
                    showingAlert = true
                }
            }
            .onAppear {
                showFileImporter = true
            }
            .alert(Localization.messages.importError, isPresented: $showingAlert) { 
                Button(Localization.labels.ok, role: .cancel) {
                    onCancel()
                }
            } message: {
                Text(alertMessage)
            }
            .onChange(of: showFileImporter) {
                if !showFileImporter && importedTodos.isEmpty && alertMessage.isEmpty {
                    onCancel()
                }
            }
        }
    }
}
