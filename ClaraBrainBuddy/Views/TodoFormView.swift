//
//  Views/TodoFormView.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//

import SwiftUI

struct TodoFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var todoViewModel: TodoViewModel

    // If nil → Add Mode | If non-nil → Edit Mode
    var existingTodo: Todo?

    @State private var title: String = ""
    @State private var details: String = ""
    @State private var dueDate: Date = Date()
    @State private var estimatedTime: Int?


    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title *")) {
                    TextField("Enter title", text: $title)
                }

                Section(header: Text("Details")) {
                    TextEditor(text: $details)
                        .frame(height: 120)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray.opacity(0.3)))
                }

                Section(header: Text("DueDate *")) {
                    DatePicker("Select due date", selection: $dueDate, displayedComponents: .date)
                }

                Section(header: Text("Estimated Time (minutes)")) {
                    TextField("e.g., 30", value: $estimatedTime, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                }
            
                Button(action: {
                    if let todo = existingTodo {
                        // Edit existing
                        var updatedTodo = todo
                        updatedTodo.title = title
                        updatedTodo.details = details
                        updatedTodo.dueDate = dueDate
                        updatedTodo.estimatedTime = estimatedTime
                        updatedTodo.updatedAt = Date()
                        todoViewModel.updateTodo(updatedTodo)
                    } else {
                        // Add new
                        todoViewModel.addTodo(title: title, details: details, dueDate: dueDate, estimatedTime: estimatedTime)
                    }
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text(existingTodo == nil ? "Add Todo" : "Save Changes")
                }
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty) 
            }
            .navigationTitle(existingTodo == nil ? "Add New Todo" : "Edit Todo")
            .onAppear {
                if let todo = existingTodo {
                    // Pre-fill for edit mode
                    title = todo.title
                    details = todo.details ?? ""
                    dueDate = todo.dueDate ?? Date()
                    estimatedTime = todo.estimatedTime
                }
            }
            
        }
    }
}
