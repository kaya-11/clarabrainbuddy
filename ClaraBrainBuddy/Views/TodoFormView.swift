//
//  Views/TodoFormView.swift
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
    @State private var dueDate: Date = Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date()
    @State private var estimatedTime: Int?
    @State private var isDone: Bool = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(Localization.labels.titleForm)) {
                    TextField(Localization.labels.titleFormTooltip, text: $title)
                        .foregroundColor(Color.theme.primary)
                }
                
                Section(header: Text(Localization.labels.details)) {
                    TextEditor(text: $details)
                        .frame(height: 120)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray.opacity(0.3)))
                }
                
                Section(header: Text(Localization.labels.dueDate)) {
                    DatePicker(Localization.labels.dueDateTooltip, selection: $dueDate, displayedComponents: .date)
                        .foregroundColor(Color.theme.primary)
                }
                
                Section(header: Text(Localization.labels.estimatedTimeForm)) {
                    TextField(Localization.labels.estimatedTimeTooltip, value: $estimatedTime, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .foregroundColor(Color.theme.primary)
                }
                
                if existingTodo != nil {
                    Section(header: Text(Localization.labels.isDone)) {
                        Toggle(Localization.labels.isDone, isOn: $isDone)
                    }
                }
                
                Button(action: {
                    if let todo = existingTodo {
                        updateTodo(todo)
                    } else {
                        todoViewModel.addTodo(title: title, details: details, dueDate: dueDate, estimatedTime: estimatedTime)
                    }
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text(existingTodo == nil ? Localization.labels.saveAddTodo : Localization.labels.saveEditTodo)
                }
                .font(Font.app.button)
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
            .onAppear {
                loadTodo()
            }
            
        }
    }
    
    func updateTodo(_ todo: Todo) {
        var updatedTodo = todo
        updatedTodo.title = title
        updatedTodo.details = details
        updatedTodo.dueDate = dueDate
        updatedTodo.estimatedTime = estimatedTime
        updatedTodo.updatedAt = Date()
        let vibrate = isDone && !todo.isDone
        updatedTodo.isDone = isDone
        todoViewModel.updateTodo(updatedTodo)
        if vibrate {
            DeviceFeedback.vibrateTwice()
        }
    }
    
    private func loadTodo() {
        if let todo = existingTodo {
            title = todo.title
            details = todo.details ?? ""
            dueDate = todo.dueDate ?? Date()
            estimatedTime = todo.estimatedTime
            isDone = todo.isDone
        }
    }
}
