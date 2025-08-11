//
//  Views/TodoFormView.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//

import SwiftUI

struct RecurringTaskFormView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var taskViewModel: TaskViewModel
    
    // If nil → Add Mode | If non-nil → Edit Mode
    var existingTask: RecurringTask?
    
    @State private var title: String = ""
    @State private var details: String = ""
    @State private var recurrenceRule: RecurrenceRule = .daily
    @State private var selectedWeekday: Int = 1 // Default to Sunday
    @State private var selectedDay: Int = 1
    @State private var estimatedTime: Int?
    
    init(taskViewModel: TaskViewModel, defaultEstimatedTime: Int?, existingTask: RecurringTask? = nil) {
        self.taskViewModel = taskViewModel
        self.existingTask = existingTask
        
        // Initialize state variables
        if let task = existingTask {
            _title = State(initialValue: task.title)
            _details = State(initialValue: task.details ?? "")
            _estimatedTime = State(initialValue: task.estimatedTime)
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
            let defaultEstimatedTime : Int = defaultEstimatedTime ?? 15
            _estimatedTime = State(initialValue: defaultEstimatedTime)
        }
    }

    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(Localization.labels.titleForm)) {
                    TextField(Localization.labels.titleFormTooltip, text: $title)
                }
                
                Section(header: Text(Localization.labels.details)) {
                    TextEditor(text: $details)
                        .frame(height: 120)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray.opacity(0.3)))
                }
                
                Section(header: Text(Localization.labels.recurrenceRule)) {
                    Picker(Localization.labels.recurrencePicker, selection: $recurrenceRule) {
                        Text(Localization.labels.recurrenceRuleDaily).tag(RecurrenceRule.daily)
                        Text(Localization.labels.recurrenceRuleWeekly).tag(RecurrenceRule.weekly(weekday: -1))
                        Text(Localization.labels.recurrenceRuleMontly).tag(RecurrenceRule.monthly(day: -1))
                        Text(Localization.labels.recurrenceRuleEvenDays).tag(RecurrenceRule.evenDays)
                        Text(Localization.labels.recurrenceRuleOddDays).tag(RecurrenceRule.oddDays)
                    }
                    
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
                
                Section(header: Text(Localization.labels.estimatedTimeForm)) {
                    TextField(Localization.labels.estimatedTimeTooltip, value: $estimatedTime, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .foregroundColor(Color.theme.primary)
                }
                
                Button(action: {
                    saveTask()
                    presentationMode.wrappedValue.dismiss()
                    
                }) {
                    Text(existingTask == nil ? Localization.labels.saveAddTodo : Localization.labels.saveEditTodo)
                }
                .font(Font.app.button)
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityIdentifier("TaskFormSaveButton")
            }
            .backgroundStyle()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(existingTask == nil ? Localization.labels.addTask : Localization.labels.editTask)
                        .foregroundColor(Color.theme.primary)
                        .font(Font.app.title)
                }
            }
        }
    }

    private func saveTask() {
        let newRecurrenceRule = updateRecurrenceRule()
        if let task = existingTask {
            var updatedTask = task
            updatedTask.title = title
            updatedTask.details = details
            updatedTask.recurrenceRule = newRecurrenceRule
            updatedTask.estimatedTime = estimatedTime
            taskViewModel.updateRecurringTask(updatedTask)
        } else {
            taskViewModel.addRecurringTask(title: title, details: details, estimatedTime: estimatedTime, recurrenceRule: newRecurrenceRule)
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

}
