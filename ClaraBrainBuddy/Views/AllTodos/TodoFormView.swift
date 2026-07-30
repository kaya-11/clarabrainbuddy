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
    @ObservedObject var categoriesViewModel: CategoryViewModel
    
    // If nil → Add Mode | If non-nil → Edit Mode
    var existingTodo: Todo?
    
    @State private var todoFormData: TodoFormData
        
    @State private var showErrorTitle: Bool = false
    @State private var errorMessageTitle: String = ""
    @State private var showErrorDetails: Bool = false
    @State private var errorMessageDetails: String = ""
    
    init(todoViewModel: TodoViewModel, addDays: Int?, existingTodo: Todo?, category: Category? = nil) {
        self.todoViewModel = todoViewModel
        self.categoriesViewModel = CategoryViewModel.shared
        
        self.existingTodo = existingTodo
        
        // Initialize the state variables
        if let todo = existingTodo {
            _todoFormData = State(
                initialValue: TodoFormData(
                    title: todo.title,
                    details: todo.details ?? "",
                    dueDate: todo.dueDate,
                    estimatedTime: todo.estimatedTime,
                    energyImpact: todo.energyImpact,
                    isDone: todo.isDone,
                    category: todo.category
                )
            )
        } else {
            let addDays = addDays ?? 14
            let dueDate: Date = Calendar.current.date(byAdding: .day, value: addDays, to: Date()) ?? Date()
            _todoFormData = State(
                initialValue: TodoFormData(
                    title: "",
                    details: "",
                    dueDate: dueDate,
                    estimatedTime: nil,
                    energyImpact: 0,
                    isDone: false,
                    category: category
                )
            )

        }
    }
    
    func validateTitle(_ name: String) {
        if name.count > TodoViewModel.TITLE_MAX_LENGTH   {
            showErrorTitle = true
            errorMessageTitle = Localization.errors.todoTitleLengthError
        } else {
            showErrorTitle = false
            errorMessageTitle = ""
        }
    }
    
    func validateDetails(_ name: String) {
        if name.count > TodoViewModel.DETAILS_MAX_LENGTH   {
            showErrorDetails = true
            errorMessageDetails = Localization.errors.todoDetailsLengthError
        } else {
            showErrorDetails = false
            errorMessageDetails = ""
        }
    }
    
    func updateTodo(_ todo: Todo) {
                    
        let vibrate = todoViewModel.updateTodo(todo, form: todoFormData)
        
        if vibrate {
            DeviceFeedback.vibrateTwice()
        }
    }
        
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(Localization.labels.titleForm)) {
                    TextField(Localization.labels.titleFormTooltip, text: $todoFormData.title)
                        .onChange(of: todoFormData.title) {
                            validateTitle(todoFormData.title)
                        }
                        .background(showErrorTitle ? Color.theme.red.opacity(0.2) : nil)
                        .accessibilityIdentifier("TodoFormTitleTextField")
                    if showErrorTitle {
                        Text(errorMessageTitle)
                            .foregroundColor(Color.theme.red)
                            .font(Font.app.small)
                    }
                }
                .sectionSytle()
                
                Section(header: Text(Localization.labels.details)) {
                    TextEditor(text: $todoFormData.details)
                        .onChange(of: todoFormData.details) {
                            validateDetails(todoFormData.details)
                        }
                        .frame(height: 120)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray.opacity(0.3)))
                        .background(showErrorDetails ? Color.red.opacity(0.2) : nil)
                        .accessibilityIdentifier("TodoFormDetailsTextField")
                    if showErrorDetails {
                        Text(errorMessageDetails)
                            .foregroundColor(Color.theme.red)
                            .font(Font.app.small)
                    }
                }
                .sectionSytle()
                
                if (categoriesViewModel.hasCategories()) {
                    Section(header: Text(Localization.labels.category)) {
                        CategoryPickerView(selectedCategory: $todoFormData.category)
                            .accessibilityIdentifier("TodoFormCategoryPicker")
                    }
                    .sectionSytle()
                }
                
                Section(header: Text(Localization.labels.dueDate)) {
                    DatePicker(Localization.labels.dueDateTooltip, selection: $todoFormData.dueDate, displayedComponents: .date)
                        .foregroundColor(Color.theme.primary)
                        .accessibilityIdentifier("TodoFormDueDateField")
                }
                .sectionSytle()
                
                Section(header: Text(Localization.labels.estimatedTimeForm)) {
                    TextField(Localization.labels.estimatedTimeTooltip, value: $todoFormData.estimatedTime, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .foregroundColor(Color.theme.primary)
                        .accessibilityIdentifier("TodoFormEstimatedTimeField")
                }
                .sectionSytle()
                
                Section(header: Text(Localization.labels.energyImpact)) {
                    HStack {
                        Battery50Icon()
                        Slider(value: Binding(
                            get: { Double(todoFormData.energyImpact ?? 0) },
                            set: { todoFormData.energyImpact = Int64($0) }
                        ), in: -1...1, step: 1)
                        .accessibilityIdentifier("TodoFormEnergyImpactField")
                        Battery100Icon()
                    }
                }
                .sectionSytle()
                
                if existingTodo != nil {
                    Section(header: Text(Localization.labels.isDone)) {
                        Toggle(Localization.labels.isDone, isOn: $todoFormData.isDone)
                            .tint(Color.theme.green)
                            .accessibilityIdentifier("TodoFormIsDoneToggle")
                    }
                    .sectionSytle()
                }
                
                Button {
                    if let todo = existingTodo {
                        updateTodo(todo)
                    } else {
                        todoViewModel.addTodo(
                            title: todoFormData.title,
                            details: todoFormData.details,
                            dueDate: todoFormData.dueDate,
                            estimatedTime: todoFormData.estimatedTime,
                            energyImpact: todoFormData.energyImpact ?? 0,
                            category: todoFormData.category)
                    }
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Label(existingTodo == nil ? Localization.labels.saveAddTodo : Localization.labels.saveEditTodo, systemImage: "none")
                        .frame(maxWidth: .infinity)
                        .bold()
                        .accessibilityLabel("TodoFormSaveButton")
                }
                .buttonStyle(.borderedProminent)
                .disabled(todoFormData.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || showErrorTitle || showErrorDetails )
                    
            }
            .appTheme()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(existingTodo == nil ? Localization.labels.addTodo : Localization.labels.editTodo)
                        .foregroundColor(Color.theme.primary)
                        .font(Font.app.header)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
