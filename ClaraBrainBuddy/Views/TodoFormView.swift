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
    
    let titleLabel = NSLocalizedString("edit.todo.title.label", comment: "Title *")
    let titleTooltip = NSLocalizedString("edit.todo.title.tooltip", comment: "Enter title")
    let detailsLabel = NSLocalizedString("edit.todo.details.label", comment: "Details")
    let dueDateLabel = NSLocalizedString("edit.todo.duedate.label", comment: "Due Date")
    let dueDateTooltip = NSLocalizedString("edit.todo.duedate.tooltip", comment: "Select Due Date")
    let estimatedtimeLabel = NSLocalizedString("edit.todo.estimatedtime.label", comment: "Estimated Time (minutes)")
    let estimatedtimeTooltip = NSLocalizedString("edit.todo.estimatedtime.tooltip", comment: "e.g., 30")
    let isDoneLabel = NSLocalizedString("edit.todo.isdone.label", comment: "Done")
    let editTodoLabel = NSLocalizedString("edit.todo.label", comment: "Edit Todo")
    let addTodoTodayLabel = NSLocalizedString("add.todo.label", comment: "Add New Todo")
    let saveAddTodoLabel = NSLocalizedString("edit.todo.save.label", comment: "Add Todo")
    let saveEditTodoLabel = NSLocalizedString("add.todo.save.label", comment: "Save Changes")

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(titleLabel)) {
                    TextField(titleTooltip, text: $title)
                        .foregroundColor(Color.theme.primary)
                }
                
                Section(header: Text(detailsLabel)) {
                    TextEditor(text: $details)
                        .frame(height: 120)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray.opacity(0.3)))
                }
                
                Section(header: Text(dueDateLabel)) {
                    DatePicker(dueDateTooltip, selection: $dueDate, displayedComponents: .date)
                        .foregroundColor(Color.theme.primary)
                }
                
                Section(header: Text(estimatedtimeLabel)) {
                    TextField(estimatedtimeTooltip, value: $estimatedTime, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .foregroundColor(Color.theme.primary)
                }
                
                if existingTodo != nil {
                    Section(header: Text(isDoneLabel)) {
                        Toggle(isDoneLabel, isOn: $isDone)
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
                    Text(existingTodo == nil ? saveAddTodoLabel : saveEditTodoLabel)
                }
                .font(Font.app.button)
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
            }
            .backgroundStyle()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(existingTodo == nil ? addTodoTodayLabel : editTodoLabel)
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
        updatedTodo.isDone = isDone
        todoViewModel.updateTodo(updatedTodo)
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
