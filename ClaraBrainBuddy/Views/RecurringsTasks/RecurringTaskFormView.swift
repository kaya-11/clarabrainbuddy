//
//  Views/RecurringTasks/RecurringTaskFormView.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//

import SwiftUI
import CoreData

struct RecurringTaskFormView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var taskViewModel: TaskViewModel
    @ObservedObject var categoriesViewModel: CategoryViewModel
    
    // If nil → Add Mode | If non-nil → Edit Mode
    var existingTask: RecurringTask?
    
    @State private var title: String = ""
    @State private var details: String = ""
    @State private var recurrenceRule: RecurrenceRule = .daily
    @State private var selectedWeekday: Int = 1 // Default to Sunday
    @State private var selectedDay: Int = 1
    @State private var estimatedTime: Int64?
    @State private var category: Category?
    
    @State private var showErrorTitle: Bool = false
    @State private var errorMessageTitle: String = ""
    @State private var showErrorDetails: Bool = false
    @State private var errorMessageDetails: String = ""
    
    init(taskViewModel: TaskViewModel, defaultEstimatedTime: Int64?, existingTask: RecurringTask? = nil) {
        
        self.taskViewModel = taskViewModel
        self.categoriesViewModel = CategoryViewModel.shared
        
        self.existingTask = existingTask
        
        // Initialize state variables
        if let task = existingTask {
            _title = State(initialValue: task.title)
            _details = State(initialValue: task.details ?? "")
            _estimatedTime = State(initialValue: task.estimatedTime)
            _category = State(initialValue: task.category)
            if case let .weekly(weekday) = task.recurrenceRule, (1...7).contains(weekday) {
                _recurrenceRule = State(initialValue: RecurrenceRule.weekly(weekday: -1))
                _selectedWeekday = State(initialValue: weekday)
            } else if case let .monthly(day) = task.recurrenceRule, day > 0 {
                _recurrenceRule = State(initialValue: RecurrenceRule.monthly(day: -1))
                _selectedDay = State(initialValue: day)
            } else {
                _recurrenceRule = State(initialValue: task.recurrenceRule)
            }
            
        } else {
            let defaultEstimatedTime  = Int64(defaultEstimatedTime ?? 15)
            _estimatedTime = State(initialValue: defaultEstimatedTime)
        }
    }

    func validateTitle(_ name: String) {
        if name.count > TaskViewModel.TITLE_MAX_LENGTH {
            showErrorTitle = true
            errorMessageTitle = Localization.errors.todoTitleLengthError
        } else {
            showErrorTitle = false
            errorMessageTitle = ""
        }
    }

    func validateDetails(_ name: String) {
        if name.count > TaskViewModel.DETAILS_MAX_LENGTH {
            showErrorDetails = true
            errorMessageDetails = Localization.errors.todoDetailsLengthError
        } else {
            showErrorDetails = false
            errorMessageDetails = ""
        }
    }
    
    private func saveTask() {
        let newRecurrenceRule = updateRecurrenceRule()
        if let task = existingTask {
            let updatedTask = task
            updatedTask.title = title
            updatedTask.details = details
            updatedTask.recurrenceRuleAsString = newRecurrenceRule.encoded()
            updatedTask.estimatedTime = estimatedTime
            updatedTask.category = category
            taskViewModel.updateRecurringTask(updatedTask)
        } else {
            taskViewModel.addRecurringTask(title: title, details: details, estimatedTime: estimatedTime, recurrenceRule: newRecurrenceRule, category: category)
        }
            
    }

    private func updateRecurrenceRule() -> RecurrenceRule {
        switch recurrenceRule {
        case .weekly:
            return RecurrenceRule.weekly(weekday: selectedWeekday)
        case .monthly:
            return RecurrenceRule.monthly(day: selectedDay)
        case .evenDays:
            return RecurrenceRule.evenDays
        case .oddDays:
            return RecurrenceRule.oddDays
        default:
            return .daily
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
                    if showErrorTitle {
                        Text(errorMessageTitle)
                            .foregroundColor(Color.theme.red)
                            .font(Font.app.small)
                    }
                }
                .accessibilityIdentifier("RecurrTaskFormTitle")
                .sectionSytle()

                
                Section(header: Text(Localization.labels.details)) {
                    TextEditor(text: $details)
                        .onChange(of: details) {
                            validateDetails(details)
                        }
                        .frame(height: 120)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray.opacity(0.3)))
                        .background(showErrorDetails ? Color.red.opacity(0.2) : nil)
                    if showErrorDetails {
                        Text(errorMessageDetails)
                            .foregroundColor(Color.theme.red)
                            .font(Font.app.small)
                    }
                }
                .sectionSytle()
                
                Section(header: Text(Localization.labels.recurrenceRule)) {
                    Picker(Localization.labels.recurrencePicker, selection: $recurrenceRule) {
                        Text(Localization.labels.recurrenceRuleDaily).tag(RecurrenceRule.daily)
                        Text(Localization.labels.recurrenceRuleWeekly).tag(RecurrenceRule.weekly(weekday: -1))
                        Text(Localization.labels.recurrenceRuleMontly).tag(RecurrenceRule.monthly(day: -1))
                        Text(Localization.labels.recurrenceRuleEvenDays).tag(RecurrenceRule.evenDays)
                        Text(Localization.labels.recurrenceRuleOddDays).tag(RecurrenceRule.oddDays)
                    }
                    .accessibilityIdentifier("RecurrTaskFormRulePicker")
                    
                    if case .weekly = recurrenceRule {
                        Picker(Localization.labels.weekday, selection: $selectedWeekday) {
                            ForEach(1..<8) { day in
                                Text(Localization.weekdays.getWeekdayName(day)).tag(day)
                            }
                        }
                    } else if case .monthly = recurrenceRule {
                        Picker(Localization.labels.dayOfMonth, selection: $selectedDay) {
                            ForEach(1..<32) { day in
                                Text("\(day)").tag(day)
                            }
                        }
                    }
                }
                .sectionSytle()
                
                if (categoriesViewModel.hasCategories()) {
                    Section(header: Text(Localization.labels.category)) {
                        CategoryPickerView(selectedCategory: $category)
                            .accessibilityIdentifier("RecurringTaskFormCategoryPicker")
                    }
                    .sectionSytle()
                }
                
                Section(header: Text(Localization.labels.estimatedTimeForm)) {
                    TextField(Localization.labels.estimatedTimeTooltip, value: $estimatedTime, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .foregroundColor(Color.theme.primary)
                        .accessibilityIdentifier("RecurringTaskFormEstimatedTimeField")
                }
                .sectionSytle()
                
                Button {
                    saveTask()
                    presentationMode.wrappedValue.dismiss()
                    
                } label: {
                    Label(existingTask == nil ? Localization.labels.saveAddTodo : Localization.labels.saveEditTodo, systemImage: "none")
                        .frame(maxWidth: .infinity)
                        .bold()
                }
                .buttonStyle()
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityIdentifier("TaskFormSaveButton")
            }
            .appTheme()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(existingTask == nil ? Localization.labels.addTask : Localization.labels.editTask)
                        .foregroundColor(Color.theme.primary)
                        .font(Font.app.header)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
