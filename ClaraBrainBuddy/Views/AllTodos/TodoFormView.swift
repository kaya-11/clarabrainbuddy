//
//  Views/AllTodos/TodoFormView.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//

import SwiftUI
import Foundation

struct TodoFormView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var todoViewModel: TodoViewModel
    
    // If nil → Add Mode | If non-nil → Edit Mode
    var existingTodo: Todo?

    @State private var title: String = ""
    @State private var details: String = ""
    @State private var dueDate: Date = Date()
    @State private var estimatedTime: Int64?
    @State private var energyImpact: Int64?
    @State private var isDone: Bool = false
    
    init(todoViewModel: TodoViewModel, addDays: Int?, existingTodo: Todo?) {
        self.todoViewModel = todoViewModel
        self.existingTodo = existingTodo

        // Initialize the state variables
        if let todo = existingTodo {
            _title = State(initialValue: todo.title)
            _details = State(initialValue: todo.details ?? "")
            _dueDate = State(initialValue: todo.dueDate)
            _estimatedTime = State(initialValue: todo.estimatedTime)
            _energyImpact = State(initialValue: todo.energyImpact)
            _isDone = State(initialValue: todo.isDone)
        } else {
            let addDays = addDays ?? 14
            _dueDate = State(initialValue: Calendar.current.date(byAdding: .day, value: addDays, to: Date()) ?? Date())
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(Localization.labels.titleForm)) {
                    TextField(Localization.labels.titleFormTooltip, text: $title)
                        .foregroundColor(Color.theme.primary)
                        .accessibilityIdentifier("TodoFormTitleTextField")
                }
                .sectionSytle()
                
                Section(header: Text(Localization.labels.details)) {
                    TextEditor(text: $details)
                        .frame(height: 120)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray.opacity(0.3)))
                        .accessibilityIdentifier("TodoFormDetailsTextField")
                }
                .sectionSytle()
                
                Section(header: Text(Localization.labels.dueDate)) {
                    DatePicker(Localization.labels.dueDateTooltip, selection: $dueDate, displayedComponents: .date)
                        .foregroundColor(Color.theme.primary)
                        .accessibilityIdentifier("TodoFormDueDateField")
                }
                .sectionSytle()
                
                Section(header: Text(Localization.labels.estimatedTimeForm)) {
                    TextField(Localization.labels.estimatedTimeTooltip, value: $estimatedTime, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .foregroundColor(Color.theme.primary)
                        .accessibilityIdentifier("TodoFormEstimatedTimeField")
                }
                .sectionSytle()
                
                Section(header: Text(Localization.labels.energyImpact)) {
                    HStack {
                        Battery25Icon()
                        Slider(value: Binding(
                            get: { Double(energyImpact ?? 0) },
                            set: { energyImpact = Int64($0) }
                        ), in: -1...1, step: 1)
                            .accessibilityIdentifier("TodoFormEnergyImpactField")
                        Battery100Icon()
                    }
                }
                .sectionSytle()
                
                if existingTodo != nil {
                    Section(header: Text(Localization.labels.isDone)) {
                        Toggle(Localization.labels.isDone, isOn: $isDone)
                            .accessibilityIdentifier("TodoFormIsDoneToggle")
                    }
                    .sectionSytle()
                }
                
                Button(action: {
                    if let todo = existingTodo {
                        updateTodo(todo)
                    } else {
                        todoViewModel.addTodo(title: title, details: details, dueDate: dueDate, estimatedTime: estimatedTime, energyImpact: energyImpact ?? 0)
                    }
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text(existingTodo == nil ? Localization.labels.saveAddTodo : Localization.labels.saveEditTodo).accessibilityLabel("TodoFormSaveButton")
                }
                .buttonStyle()
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
            }
            .backgroundStyle()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(existingTodo == nil ? Localization.labels.addTodo : Localization.labels.editTodo)
                        .foregroundColor(Color.theme.primary)
                        .font(Font.app.title)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func updateTodo(_ todo: Todo) {
        let updatedTodo = todo
        updatedTodo.title = title
        updatedTodo.details = details
        updatedTodo.dueDate = dueDate
        updatedTodo.estimatedTime = estimatedTime
        updatedTodo.energyImpact = energyImpact ?? 0
        updatedTodo.updatedAt = Date()
        let vibrate = isDone && !todo.isDone
        updatedTodo.isDone = isDone
        todoViewModel.updateTodo(updatedTodo)
        if vibrate {
            DeviceFeedback.vibrateTwice()
        }
    }
}
