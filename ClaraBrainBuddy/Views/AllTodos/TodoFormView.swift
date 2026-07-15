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

    @State private var title: String = ""
    @State private var details: String = ""
    @State private var dueDate: Date = Date()
    @State private var estimatedTime: Int64?
    @State private var energyImpact: Int64?
    @State private var isDone: Bool = false
    @State private var category: Category?
    
    @State private var ogDueDate: Date = Date()
    
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
            _title = State(initialValue: todo.title)
            _details = State(initialValue: todo.details ?? "")
            _dueDate = State(initialValue: todo.dueDate)
            _estimatedTime = State(initialValue: todo.estimatedTime)
            _energyImpact = State(initialValue: todo.energyImpact)
            _category = State(initialValue: todo.category)
            _isDone = State(initialValue: todo.isDone)
            _ogDueDate = State(initialValue: todo.dueDate)
        } else {
            let addDays = addDays ?? 14
            _dueDate = State(initialValue: Calendar.current.date(byAdding: .day, value: addDays, to: Date()) ?? Date())
            _category = State(initialValue: category) 
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
        
        let todoFormData = TodoFormData(
            title: title,
            details: details,
            dueDate: dueDate,
            estimatedTime: estimatedTime,
            energyImpact: energyImpact ?? 0,
            isDone: isDone,
            category: category)
            
        let vibrate = todoViewModel.updateTodo(todo, form: todoFormData)
        
        if vibrate {
            DeviceFeedback.vibrateTwice()
        }
    }
        
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(Localization.labels.titleForm)) {
                    TextField(Localization.labels.titleFormTooltip, text: $title)
                        .onChange(of: title) {
                            validateTitle(title)
                        }
                        .background(showErrorTitle ? Color.red.opacity(0.2) : nil)
                        .foregroundColor(Color.theme.primary)
                        .accessibilityIdentifier("TodoFormTitleTextField")
                    if showErrorTitle {
                        Text(errorMessageTitle)
                            .foregroundColor(Color.theme.red)
                            .font(Font.app.small)
                    }
                }

                .sectionSytle()
                
                Section(header: Text(Localization.labels.details)) {
                    TextEditor(text: $details)
                        .onChange(of: details) {
                            validateDetails(details)
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
                        CategoryPickerView(selectedCategory: $category)
                            .accessibilityIdentifier("TodoFormCategoryPicker")
                    }
                    .sectionSytle()
                }
                
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
                        Battery50Icon()
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
                        todoViewModel.addTodo(title: title, details: details, dueDate: dueDate, estimatedTime: estimatedTime, energyImpact: energyImpact ?? 0, category: category)
                    }
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text(existingTodo == nil ? Localization.labels.saveAddTodo : Localization.labels.saveEditTodo).accessibilityLabel("TodoFormSaveButton")
                }
                .buttonStyle()
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || showErrorTitle || showErrorDetails )
                    
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
