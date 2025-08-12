//
//  Views/TodoFormView.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//

import SwiftUI
import Foundation

struct TodoTodayFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var todoViewModel: TodoViewModel

    @State private var title: String
    @State private var details: String
    @State private var dueDate: Date
    @State private var estimatedTime: Int64?
    @State private var isDone: Bool
    
    init(todoViewModel: TodoViewModel) {
        self.todoViewModel = todoViewModel
        
        _title = State(initialValue: "" )
        _details = State(initialValue: "")
        _dueDate = State(initialValue: Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date())
        _estimatedTime = State(initialValue: nil)
        _isDone = State(initialValue: false)
    }
    
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
                
                Section(header: Text(Localization.labels.estimatedTimeForm)) {
                    TextField(Localization.labels.estimatedTimeTooltip, value: $estimatedTime, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .foregroundColor(Color.theme.primary)
                }
                
                
                Button(action: {
                    todoViewModel.addNewTodoForToday(title: title, details: details, estimatedTime: estimatedTime)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text(Localization.labels.saveAddTodo)
                }
                .font(Font.app.button)
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityLabel("TodaysTodoFormSaveButton")
                    
            }
            .backgroundStyle()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(Localization.labels.addTodoToday)
                        .foregroundColor(Color.theme.primary)
                        .font(Font.app.title)
                }
            }
        }
    }
}
