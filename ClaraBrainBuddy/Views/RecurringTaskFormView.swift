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
                
                Section(header: Text("Recurrence Rule")) {
                    Picker("Recurrence", selection: $recurrenceRule) {
                        Text("Daily").tag(RecurrenceRule.daily)
                        Text("Weekly").tag(RecurrenceRule.weekly(weekday: -1))
                        Text("Monthly").tag(RecurrenceRule.monthly(day: -1))
                    }
                    
                    if case .weekly = recurrenceRule {
                        Picker("Weekday", selection: $selectedWeekday) {
                            ForEach(1..<8) { day in
                                Text(weekdayName(day)).tag(day)
                            }
                        }
                    } else if case .monthly = recurrenceRule {
                        Picker("Day of Month", selection: $selectedDay) {
                            ForEach(1..<32) { day in
                                Text("\(day)").tag(day)
                            }
                        }
                    }
                }
                
                Button(action: {
                    saveTask()
                    presentationMode.wrappedValue.dismiss()
                    
                }) {
                    Text(existingTask == nil ? "Add Todo" : "Save Changes")
                }
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .navigationTitle(existingTask == nil ? "Add New Recurring Task" : "Edit Recurring Task")
            .onAppear {
                loadTask()
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
            taskViewModel.updateRecurringTask(updatedTask)
        } else {
            taskViewModel.addRecurringTask(title: title, details: details, recurrenceRule: newRecurrenceRule)
        }
    }

    private func updateRecurrenceRule() -> RecurrenceRule {
        switch recurrenceRule {
        case .weekly:
            return RecurrenceRule.weekly(weekday: selectedWeekday)
        case .monthly:
            return RecurrenceRule.monthly(day: selectedDay)
        default:
            return .daily
        }
    }

    private func loadTask() {
        if let task = existingTask {
            title = task.title
            details = task.details ?? ""
            if case let .weekly(weekday) = task.recurrenceRule, (1...7).contains(weekday) {
                recurrenceRule = RecurrenceRule.weekly(weekday: -1)
                selectedWeekday = weekday
            } else if case let .monthly(day) = task.recurrenceRule, day > 0 {
                recurrenceRule = RecurrenceRule.monthly(day: -1)
                selectedDay = day
            }
        }
    }

    private func weekdayName(_ day: Int) -> String {
        ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"][day - 1]
    }
}
