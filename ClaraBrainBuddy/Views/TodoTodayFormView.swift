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

    @State private var title: String = ""
    @State private var details: String = ""
    @State private var dueDate: Date = Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date()
    @State private var estimatedTime: Int?
    @State private var isDone: Bool = false
    
    let titleLabel = NSLocalizedString("edit.todo.title.label", comment: "Title *")
    let titleTooltip = NSLocalizedString("edit.todo.title.tooltip", comment: "Enter title")
    let detailsLabel = NSLocalizedString("edit.todo.details.label", comment: "Details")
    let estimatedtimeLabel = NSLocalizedString("edit.todo.estimatedtime.label", comment: "Estimated Time (minutes)")
    let estimatedtimeTooltip = NSLocalizedString("edit.todo.estimatedtime.tooltip", comment: "e.g., 30")
    let isDoneLabel = NSLocalizedString("edit.todo.isdone.label", comment: "Done")
    let addTodoTodayLabel = NSLocalizedString("add.todo.for.today.label", comment: "Add New Todo For Today")
    let saveAddTodoLabel = NSLocalizedString("edit.todo.save.label", comment: "Add Todo")

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
                
                Section(header: Text(estimatedtimeLabel)) {
                    TextField(estimatedtimeTooltip, value: $estimatedTime, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .foregroundColor(Color.theme.primary)
                }
                
                
                Button(action: {
                   todoViewModel.addNewTodoForToday(title: title, details: details, estimatedTime: estimatedTime)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text(saveAddTodoLabel)
                }
                .font(Font.app.button)
                    
            }
            .backgroundStyle()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(addTodoTodayLabel)
                        .foregroundColor(Color.theme.primary)
                        .font(Font.app.title)
                }
            }
        }
    }
}
