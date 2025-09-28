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
    static let errors = Errors()
    static let about = About()
    
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
        let swipeRightRandomTodo1 = NSLocalizedString("random.todo.popup.explanation.swipe.right.1", comment: "Swipe right to keep.")
        let swipeRightRandomTodo2 = NSLocalizedString("random.todo.popup.explanation.swipe.right.2", comment: "Priorize lower.")
        let tapToSelectRandomTodo1 = NSLocalizedString("random.todo.popup.explanation.tab.1", comment: "Or tap")
        let tapToSelectRandomTodo2 = NSLocalizedString("random.todo.popup.explanation.tab.2", comment: "to select for today.")
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
        
        let todosDone = NSLocalizedString("todos.done.label", comment: "Todos done")
        let timeNeeded = NSLocalizedString("time.needed.label", comment: "Time needed")
        
        // Properties and Clara Main Menu
        let properties = NSLocalizedString("properties.label", comment: "Open properties")
        let maxTodosForToday = NSLocalizedString("properties.max.todos.for.today", comment: "Max Todos for Today")
        let defaultEstimatedTime = NSLocalizedString("properties.default.estimated.time", comment: "Default Estimated Time for Recurring Tasks (minutes)")
        let defaultEnergyLevelCalculation = NSLocalizedString("properties.default.energylevel.calculation", comment: "Default Time for Energy Level Calculation (minutes)")
        let daysAddedForDueDate = NSLocalizedString("properties.days.added.for.duedate", comment: "Days to add for Default Due Date")
        let openCalendar = NSLocalizedString("open.calendar", comment: "Open Calendar")
        let about = NSLocalizedString("about.label", comment: "About")
        let importTodo = NSLocalizedString("import.label", comment: "Import todos")
        let todaysEvents = NSLocalizedString( "todays.events.label", comment: "Todays Events")
        
        // Buttons
        let back = NSLocalizedString("back.label", comment: "Back")
        let save = NSLocalizedString("save.label", comment: "Save")
        let ok = NSLocalizedString("ok.label", comment: "Ok")
        let clone = NSLocalizedString("clone.label", comment: "Clone")
        let done = NSLocalizedString("done.label", comment: "Done")
        let copy = NSLocalizedString("copy.label", comment: "Copy")
        let remove = NSLocalizedString("remove.label", comment: "Remove")
        let cancel = NSLocalizedString("cancel.label", comment: "Abbrechen")
        let importing = NSLocalizedString("import.label", comment: "Importieren")
        let previewImport = NSLocalizedString("import.preview.label", comment: "Vorschau des Imports")
        
        let shareDetails = NSLocalizedString("share.details.label", comment: "Share details")
        let exportAll = NSLocalizedString("export.all.label", comment: "Export All Todos")
        
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
        let noValidTodos = NSLocalizedString("no.valid.todos", comment: "Keine gültigen Todos vorhanden...")
        let selectFileToImport = NSLocalizedString("message.import.select.file", comment: "Select Import File")
        let importError = NSLocalizedString("message.import.error", comment: "Import error")
        
    }
    
    struct Errors {
        let fileNotFound = NSLocalizedString("error.filenotfound", comment: "File not found")
        let emptyFile = NSLocalizedString("error.emptyfile", comment: "Empty file")
        let invalidJSON = NSLocalizedString("error.invalidjson", comment: "Invalid JSON")
    }
    
    struct About {
        let claraBrainBuddyTitle = NSLocalizedString("about.claraBrainBuddy.title", comment: "Title for the About Clara BrainBuddy section")
        let claraBrainBuddyDescription = NSLocalizedString("about.claraBrainBuddy.description", comment: "Description of Clara BrainBuddy")

        let featureTodosTitle = NSLocalizedString("about.feature.todos.title", comment: "Title for Todos feature")
        let featureTodosDescription = NSLocalizedString("about.feature.todos.description", comment: "Description for Todos feature")

        let featureRecurringTasksTitle = NSLocalizedString("about.feature.recurringTasks.title", comment: "Title for Recurring Tasks feature")
        let featureRecurringTasksDescription = NSLocalizedString("about.feature.recurringTasks.description", comment: "Description for Recurring Tasks feature")

        let featureHapticFeedbackTitle = NSLocalizedString("about.feature.hapticFeedback.title", comment: "Title for Haptic Feedback feature")
        let featureHapticFeedbackDescription = NSLocalizedString("about.feature.hapticFeedback.description", comment: "Description for Haptic Feedback feature")

        let featureSortTitle = NSLocalizedString("about.feature.sort.title", comment: "Title for Sort feature")
        let featureSortDescription = NSLocalizedString("about.feature.sort.description", comment: "Description for Sort feature")

        let featureFeedbackTitle = NSLocalizedString("about.feature.feedback.title", comment: "Title for Feedback feature")
        let featureFeedbackDescription = NSLocalizedString("about.feature.feedback.description", comment: "Description for Feedback feature")

        let featureSharingTitle = NSLocalizedString("about.feature.sharing.title", comment: "Title for Sharing feature")
        let featureSharingDescription = NSLocalizedString("about.feature.sharing.description", comment: "Description for Sharing feature")

        let featureNeurodivergentTitle = NSLocalizedString("about.feature.neurodivergent.title", comment: "Title for Neurodivergent feature")
        let featureNeurodivergentDescription = NSLocalizedString("about.feature.neurodivergent.description", comment: "Description for Neurodivergent feature")

        let developer = NSLocalizedString("about.developer", comment: "Developer information")
        let copyright = NSLocalizedString("about.copyright", comment: "Copyright information")
        
        let plannedExtensionsTitle = NSLocalizedString("about.plannedExtensions.title", comment: "Note about planned extensions")

        let plannedNote = NSLocalizedString("about.planned.note", comment: "Note about planned extensions")

        let featureSearchTitle = NSLocalizedString("about.feature.search.title", comment: "Title for Search extension")
        let featureSearchDescription = NSLocalizedString("about.feature.search.description", comment: "Description for Search extension")

        let featureTaskSetsTitle = NSLocalizedString("about.feature.taskSets.title", comment: "Title for Task Sets extension")
        let featureTaskSetsDescription = NSLocalizedString("about.feature.taskSets.description", comment: "Description for Task Sets extension")

        let featureCategoriesTitle = NSLocalizedString("about.feature.categories.title", comment: "Title for Categories extension")
        let featureCategoriesDescription = NSLocalizedString("about.feature.categories.description", comment: "Description for Categories extension")

        let featureAISupportTitle = NSLocalizedString("about.feature.aiSupport.title", comment: "Title for AI Support extension")
        let featureAISupportDescription = NSLocalizedString("about.feature.aiSupport.description", comment: "Description for AI Support extension")
    }
    
}
