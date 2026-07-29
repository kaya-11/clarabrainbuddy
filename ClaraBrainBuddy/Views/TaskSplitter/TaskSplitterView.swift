//
//  TaskSplitterView.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 29.07.26.
//

import SwiftUI
import FoundationModels

// TODO: Alles noch mal ansehen
// TODO: CATEGORY DROPDOWN
// TODO: Ein vorhandenes Todo zerlegen

@available(iOS 26.0, *)
struct TaskSplitterView: View {

    @State private var taskInput: String = ""
    @State private var suggestions: [TodoDto] = []
    @State private var selectedIDs: Set<UUID> = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    @State private var service = TaskSplitterService()
    
    @State private var showingInfo = false

    @Environment(\.dismiss) private var dismiss
    
    var category: CategoryDto? = nil
    
    var onGenerate: ((String) async throws -> [TodoDto])? = nil
    
    var onAccept: ([TodoDto]) async throws -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                inputSection

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(Color.theme.red)
                        .padding(.horizontal)
                }

                suggestionList
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Localization.labels.cancel) { dismiss() }
                }
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text(Localization.labels.splittingTasks)
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
                                title: Localization.info.infoTaskSplitterTitle,
                                explanationText: Localization.info.infoTaskSplitterText,
                                buttonText: nil,
                                buttonAction: nil
                            )
                        }
                    }
                    .foregroundColor(Color.theme.primary)
                }
            }
            .safeAreaInset(edge: .bottom) {
                if !suggestions.isEmpty {
                    acceptButton
                }
            }
        }
    }

    private var inputSection: some View {
        VStack(spacing: 12) {
            TextField(
                Localization.messages.splittingTasksExample,
                text: $taskInput,
                axis: .vertical
            )
            .textFieldStyle(.roundedBorder)
            .lineLimit(2...4)
            .submitLabel(.done)

            Button {
                generate()
            } label: {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Label(Localization.labels.splitting, systemImage: "sparkles")
                        .frame(maxWidth: .infinity)
                        .bold()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(taskInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
        }
        .padding(.horizontal)
    }

    private var suggestionList: some View {
        List(suggestions) { todo in
            Button {
                toggleSelection(for: todo)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: isSelected(todo) ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isSelected(todo) ? Color.theme.accent : Color.theme.secondary)
                        .imageScale(.large)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(todo.title)
                            .font(Font.app.small)
                            .foregroundStyle(Color.theme.primary)
                        Text(todo.details ?? "")
                            .font(Font.app.tiny)
                            .foregroundStyle(Color.theme.primary)
                        Text("\(todo.dueDate, formatter: StyleUtils.dateFormatter)")
                            .font(Font.app.tiny)
                            .foregroundColor(Color.theme.primary)
                    }
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .listStyle(.plain)
        .overlay {
            if suggestions.isEmpty && !isLoading {
                ContentUnavailableView(
                    Localization.messages.splittingTasksNoRecommendations,
                    systemImage: "list.bullet.rectangle",
                    description: Text(Localization.messages.splittingTasksHelp)
                )
            }
        }
    }

    private var acceptButton: some View {
        Button {
            let selected = suggestions.filter { selectedIDs.contains($0.id) }
            Task {
                await accept(selected: selected)
                if errorMessage == nil {
                    dismiss()
                }
            }
        } label: {
            Text("\(Localization.labels.takeOver) \(selectedIDs.count)")
                .frame(maxWidth: .infinity)
                .bold()
        }
        .buttonStyle(.borderedProminent)
        .disabled(selectedIDs.isEmpty)
        .padding()
        .background(Color.theme.background) // TODO: ???
    }

    private func generate() {
        Task {
            isLoading = true
            errorMessage = nil
            suggestions = []
            selectedIDs = []

            do {
                let result: [TodoDto]
                if let onGenerate {
                    result = try await onGenerate(taskInput)
                } else {
                    result = try await service.split(taskInput, category: category)
                }
                suggestions = result
                selectedIDs = Set(result.map(\.id))
            }  catch  {
                errorMessage = Localization.errors.taskSplittingError.replacingOccurrences(of: "{0}", with: error.localizedDescription)
            }

            isLoading = false
        }
    }
    
    private func accept(selected: [TodoDto]) async {
        do {
            try await onAccept(selected)
        } catch {
            errorMessage = Localization.errors.taskSplittingError.replacingOccurrences(of: "{0}", with: error.localizedDescription)
        }
    }

    private func isSelected(_ todo: TodoDto) -> Bool {
        selectedIDs.contains(todo.id)
    }

    private func toggleSelection(for todo: TodoDto) {
        if selectedIDs.contains(todo.id) {
            selectedIDs.remove(todo.id)
        } else {
            selectedIDs.insert(todo.id)
        }
    }
}

@available(iOS 26.0, *)
#Preview("Mit Vorschlägen") {
    TaskSplitterView(
        onGenerate: { _ in
            // Simulierte Modell-Antwort für die Preview
            try await Task.sleep(for: .seconds(1))
            return [
                TodoDto(title: "Trainingsplan erstellen"),
                TodoDto(title: "Laufschuhe kaufen"),
                TodoDto(title: "Erste Trainingswoche starten")
            ]
        },
        onAccept: { selected in
            print("Übernommen: \(selected.map(\.title))")
        }
    )
}

@available(iOS 26.0, *)
#Preview("Leer") {
    TaskSplitterView(onAccept: { _ in })
}
