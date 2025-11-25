//
//  Managers/ImportManager.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 25.11.25.
//


import SwiftUI

@MainActor
final class ExternalImportManager: ObservableObject {
    static let shared = ExternalImportManager()

    @Published var importedTodos: [TodoDto] = []
    @Published var showImportPreview: Bool = false
    @Published var alertMessage: String = ""
    @Published var showingAlert: Bool = false

    private init() {}

    /// Handle file URL from AirDrop / Open In
    func handleFile(url: URL) async {
        var needsStop = false
        if url.startAccessingSecurityScopedResource() {
            needsStop = true
        }

        defer {
            if needsStop { url.stopAccessingSecurityScopedResource() }
        }

        do {
            let todos = try ImportExportUtils.importTodosFromJSONFile(fileURL: url)
            importedTodos = todos
            showImportPreview = true
        } catch let error as ImportExportError {
            alertMessage = error.errorDescription ?? ""
            showingAlert = true
        } catch {
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }

    func cancelImport() {
        importedTodos = []
        showImportPreview = false
    }
}
