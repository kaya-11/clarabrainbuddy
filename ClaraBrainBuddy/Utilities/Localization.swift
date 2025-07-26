//
//  Localization.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 29.03.25.
//

import Foundation

struct Localization {
    
    static let labels = Labels()
    static let messages = Messages()
    static let weekdays = Weekdays()
    
    struct Greetings {
        static let hello = NSLocalizedString("hello", comment: "Hello")
        static let goodbye = NSLocalizedString("goodbye", comment: "Goodbye")
    }
    
    struct Labels {
        
        // General
        let edit = NSLocalizedString("edit.label", comment: "Edit")
        let delete = NSLocalizedString("delete.label", comment: "Delete")
        let today = NSLocalizedString("today.label", comment: "Today")
        let weekday = NSLocalizedString("weekday.label", comment: "Weekday")
        let dayOfMonth = NSLocalizedString("dayofmonth.label", comment: "Day Of Month")
        
        // Navigation
        let allTodosNav = NSLocalizedString("navigation.alltodos", comment: "Navigation All Todos")
        let todayNav = NSLocalizedString("navigation.today", comment: "Navigation Today")
        let recurringTasksNav = NSLocalizedString("navigation.recurringtasks", comment: "Navigation Recurring Tasks")
        
        // Random Todo View
        let titleRandomTodoPopup = NSLocalizedString("random.todo.popup.title", comment: "What would you like to do?")
        let swipeLeftRandomTodo = NSLocalizedString("random.todo.popup.explanation.swipe.left", comment: "Swipe left to delete.")
        let swipeRightRandomTodo = NSLocalizedString("random.todo.popup.explanation.swipe.right", comment: "Swipe right to keep, but prioritize lower.")
        let tapToSelectRandomTodo = NSLocalizedString("random.todo.popup.explanation.tab", comment: "Or tap to select for today.")
        let noTodosRandomTodo = NSLocalizedString("random.todo.popup.no.todo.available", comment: "No todos available...")
        
        // All Todos
        let titleAllTodos = NSLocalizedString("title.alltodos", comment: "All Todos")
        
        // Today's View
        let titleToday = NSLocalizedString("title.today", comment: "Today")
        
        let noTodosToday = NSLocalizedString("message.no.todos.today", comment: "No todo's today")
        let todosPickedForToday = NSLocalizedString("message.todos.picked.today", comment: "Todo's for today")
        let recurringTasksToday = NSLocalizedString("message.recurring.tasks.today", comment: "Recurring Task's today")
        
        let estimatedTime = NSLocalizedString("message.estimated.time", comment: "Estimeted time")
        let estimatedTimeUnit = NSLocalizedString("message.estimated.time.unit", comment: "min.")
        
        let addForToday = NSLocalizedString("action.add.for.today", comment: "Add for today")
        
        // Recurring Tasks View
        let titleRecurringTasks = NSLocalizedString("title.recurringtasks", comment: "Recurring Tasks")
        
        // Todo, TodaysTodo and RecurringTask Form
        let titleForm = NSLocalizedString("edit.todo.title.label", comment: "Title *")
        let titleFormTooltip = NSLocalizedString("edit.todo.title.tooltip", comment: "Enter title")
        let details = NSLocalizedString("edit.todo.details.label", comment: "Details")
        let dueDate = NSLocalizedString("edit.todo.duedate.label", comment: "Due Date")
        let dueDateTooltip = NSLocalizedString("edit.todo.duedate.tooltip", comment: "Select Due Date")
        let estimatedTimeForm = NSLocalizedString("edit.todo.estimatedtime.label", comment: "Estimated Time (minutes)")
        let estimatedTimeTooltip = NSLocalizedString("edit.todo.estimatedtime.tooltip", comment: "e.g., 30")
        let isDone = NSLocalizedString("edit.todo.isdone.label", comment: "Done")
        let editTodo = NSLocalizedString("edit.todo.label", comment: "Edit Todo")
        let addTodo = NSLocalizedString("add.todo.label", comment: "Add New Todo")
        let addTodoToday = NSLocalizedString("add.todo.for.today.label", comment: "Add New Todo For Today")
        let saveAddTodo = NSLocalizedString("edit.todo.save.label", comment: "Save Changes")
        let saveEditTodo = NSLocalizedString("add.todo.save.label", comment: "Add Todo")
        let due = NSLocalizedString("due.label", comment: "Due")
        
        let recurrenceRule = NSLocalizedString("recurrence.rule.label", comment: "Recurrence Rule")
        let recurrencePicker = NSLocalizedString("recurrence.picker.label", comment: "Recurrence")
        let recurrenceRuleDaily = NSLocalizedString("recurrence.rule.daily.label", comment: "Daily")
        let recurrenceRuleWeekly = NSLocalizedString("recurrence.rule.weekly.label", comment: "Weekly")
        let recurrenceRuleMontly = NSLocalizedString("recurrence.rule.monthly.label", comment: "Monthly")
        let recurrenceRuleEvenDays = NSLocalizedString("recurrence.rule.evendays.label", comment: "Even Days")
        let recurrenceRuleOddDays = NSLocalizedString("recurrence.rule.odddays.label", comment: "Odd Days")
        let editTask = NSLocalizedString("edit.task.label", comment: "Edit Recurring Task")
        let addTask = NSLocalizedString("add.task.label", comment: "Add New Recurring Task")
        
        // Properties and Clara Main Menu
        let properties = NSLocalizedString("properties.label", comment: "Open properties")
        let maxTodosForToday = NSLocalizedString("properties.max.todos.for.today", comment: "Max Todos for Today")
        let defaultEstimatedTime = NSLocalizedString("properties.default.estimated.time", comment: "Default Estimated Time for Recurring Tasks (minutes)")
        let defaultEnergyLevelCalculation = NSLocalizedString("properties.default.energylevel.calculation", comment: "Default Time for Energy Level Calculation (minutes)")
        let daysAddedForDueDate = NSLocalizedString("properties.days.added.for.duedate", comment: "Days to add for Default Due Date")
        let openCalendar = NSLocalizedString("open.calendar", comment: "Open Calendar")
        
        // Buttons
        let back = NSLocalizedString("back.label", comment: "Back")
        let save = NSLocalizedString("save.label", comment: "Save")
        let ok = NSLocalizedString("ok.label", comment: "Ok")
        let clone = NSLocalizedString("clone.label", comment: "Clone")
        let done = NSLocalizedString("done.label", comment: "Done")
        let copy = NSLocalizedString("copy.label", comment: "Copy")
        let remove = NSLocalizedString("remove.label", comment: "Remove")
        
        let shareDetails = NSLocalizedString("share.details.label", comment: "Share details")
        
    }
    
    struct Weekdays {
        let sunday = NSLocalizedString("weekday.sunday", comment: "Sunday")
        let monday = NSLocalizedString("weekday.monday", comment: "Monday")
        let tuesday = NSLocalizedString("weekday.tuesday", comment: "Tuesday")
        let wednesday = NSLocalizedString("weekday.wednesday", comment: "Wednesday")
        let thursday = NSLocalizedString("weekday.thursday", comment: "Thursday")
        let friday = NSLocalizedString("weekday.friday", comment: "Friday")
        let saturday = NSLocalizedString("weekday.saturday", comment: "Saturday")
        
        func getWeekdayName(_ day: Int) -> String {
            [sunday, monday, tuesday, wednesday, thursday, friday, saturday][day - 1]
        }
        
    }
    
    struct Messages {
        let energyLevel = NSLocalizedString("message.energy.level", comment: "Energy Level")
        let energyLevelLow = NSLocalizedString("message.energy.level.low", comment: "low")
        let energyLevelMedium = NSLocalizedString("message.energy.level.medium", comment: "medium")
        let energyLevelHigh = NSLocalizedString("message.energy.level.high", comment: "high")
        let limitExeeded = NSLocalizedString("message.limit.exeeded", comment: "Limit Exceeded")
        let limitExeededMessage = NSLocalizedString("message.limit.exeeded.message", comment: "You cannot add more than %@ todos for today.")
    }

    struct Errors {
        static let networkError = NSLocalizedString("network_error", comment: "Network error message")
        static let unknownError = NSLocalizedString("unknown_error", comment: "Unknown error message")
    }

    // Add more categories as needed
}
