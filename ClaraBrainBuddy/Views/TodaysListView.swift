//
//  Views/DailyTodoView.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//

import SwiftUI

struct TodaysListView: View {
    
    @ObservedObject var todoViewModel: TodoViewModel
    @ObservedObject var taskViewModel: TaskViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel
    
    @State private var showingAddTodo = false
    @State private var selectedTodo: Todo? = nil
    @State private var showErrorMessage = false
    @State private var sharedTodoDetails: SharedTodoDetailsWrapper? = nil
    @State private var energyLevel: Float = EnergyManager.EnergyLevel.medium.rawValue
    
    @Environment(\.managedObjectContext) private var context
     
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TodayTodo.sortOrder, ascending: true)]
    ) private var todayTodos: FetchedResults<TodayTodo>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \RecurringTask.sortOrder, ascending: true)]
    ) private var tasks: FetchedResults<RecurringTask>
        
    init(todoViewModel: TodoViewModel, taskViewModel: TaskViewModel, settingsViewModel: SettingsViewModel) {
        self.todoViewModel = todoViewModel
        self.taskViewModel = taskViewModel
        self.settingsViewModel = settingsViewModel
    }
    
    var recurringTasks: [RecurringTask] {
        let now = Date()
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: now)
        let day = calendar.component(.day, from: now)
        let lastDay = (calendar.range(of: .day, in: .month, for: now)?.upperBound ?? 32) - 1
        let dayToCompare = min(day, lastDay)
        let isEven = day.isMultiple(of: 2)
        let isWeekend = (weekday == 1) || (weekday == 7)
        
        let safeTasks: [RecurringTask] = tasks.filter { !$0.isDeleted && $0.managedObjectContext != nil }
        
        return safeTasks.filter { (task : RecurringTask) in
            let matchesRecurrence: Bool
            switch task.recurrenceRule {
            case .daily:
                matchesRecurrence = true
            case .weekly(let wd):
                matchesRecurrence = wd == weekday
            case .monthly(let d):
                matchesRecurrence = d == dayToCompare
            case .evenDays:
                matchesRecurrence = isEven && !isWeekend
            case .oddDays:
                matchesRecurrence = !isEven && !isWeekend
            }
            return matchesRecurrence && !todoViewModel.isRecurringTaskInTodayTodos(task)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                
                if todayTodos.isEmpty && recurringTasks.isEmpty {
                    Text(Localization.labels.noTodosToday)
                        .foregroundColor(Color.theme.primary)
                        .font(.title)
                        .padding()
                } else {
                    
                    Text("\(Localization.labels.todosPickedForToday):")
                            .foregroundColor(Color.theme.primary)
                            .font(Font.app.listHeader)
                            .textCase(.none)
                            .padding(.top, 28)
                    
                    List {
                        ForEach(todayTodos, id: \.objectID) { (todayTodo: TodayTodo) in
                            let todo: Todo = todayTodo.todo
                                
                            let isDone: Bool = todo.isDone
                            let title: String = todo.title
                            let details: String = todo.details ?? ""
                            let dueDate: Date = todo.dueDate
                            let resistance: Int64 = todo.resistance
                               
                            VStack(alignment: .leading, spacing: 4) {
                            
                                HStack {
                                    if isDone {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Color.theme.green)
                                    }
                                    Text(title)
                                        .accessibilityValue(isDone ? "done" : "active")
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if !details.isEmpty {
                                    Text(String(details.prefix(20)) + (details.count > 20 ? "..." : ""))
                                        .font(Font.app.tiny)
                                        .foregroundColor(Color.theme.secondary)
                                }
                                
                                Text("\(Localization.labels.due): \(dueDate, formatter: StyleUtils.dateFormatter)")
                                    .font(Font.app.tiny)
                                    .foregroundColor(Color.theme.secondary)
                                
                                if (1...10).contains(Int(resistance)) {
                                    HStack {
                                        ForEach(1...Int(resistance), id: \.self) { (value: Int) in
                                            Image(systemName: "mountain.2")
                                                .foregroundColor(StyleUtils.iconFontColorForLevels(for: value))
                                                .imageScale(.small)
                                                .font(StyleUtils.iconFontSizeForLevels(for: value))
                                        }
                                    }
                                }
                            }
                            .onTapGesture(count: 2) {
                                selectedTodo = todo
                            }
                            .strikethrough(isDone, color: Color.theme.primary)
                            .italic(isDone)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                
                                Button(role: .destructive) {
                                    todoViewModel.deselectForToday(todo)
                                } label: {
                                    Label(Localization.labels.remove, systemImage: "minus.square")
                                }
                                .tint(.orange)
                                .accessibilityIdentifier("RemoveFromTodaysTodos")
                                
                                Button(role: .destructive) {
                                    todoViewModel.deleteTodo(todo)
                                } label: {
                                    Label(Localization.labels.delete, systemImage: "trash")
                                }
                                .tint(.red)
                                .accessibilityIdentifier("TodaysTodosDeleteTodo")
                                
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                
                                Button {
                                    todoViewModel.setToDone(todo)
                                    DeviceFeedback.vibrateTwice()
                                } label: {
                                    Label(Localization.labels.done, systemImage: "checkmark.square")
                                }
                                .tint(.blue)
                                .accessibilityIdentifier("MarkAsDoneButton")
                                
                                Button {
                                    selectedTodo = todo
                                } label: {
                                    Label(Localization.labels.edit, systemImage: "pencil")
                                }
                                .tint(.green)
                                
                                Button {
                                    sharedTodoDetails = SharedTodoDetailsWrapper(todo: todo)
                                } label: {
                                    Label(Localization.labels.copy, systemImage: "doc.on.doc")
                                }
                                .tint(.cyan)
                                
                                Button {
                                    todoViewModel.cloneTodo(todo: todo)
                                } label: {
                                    Label(Localization.labels.clone, systemImage: "plus.square.on.square")
                                }
                                .tint(.gray)
                                
                            }
                            .foregroundColor(StyleUtils.getTextColor(todo: todo, isSelectedForToday: false))
                            .listRowBackground(Color.theme.listBackground)
                            .font(Font.app.listItem)
                        }
                        .onMove(perform: move)
                    }
                    .background(Color.background)
                    .frame(width: 400, height: recurringTasks.isEmpty ? 450 : 300)
                    
                    if (!recurringTasks.isEmpty) {
                        Text("\(Localization.labels.recurringTasksToday):")
                            .foregroundColor(Color.theme.primary)
                            .font(Font.app.listHeader)
                            .textCase(.none)
                            .padding(.top, 28)
                        
                        List {
                            ForEach(recurringTasks, id: \.objectID) { (todaysTask: RecurringTask) in
                                let title = todaysTask.title
                                Text(title)
                                    .foregroundColor(Color.theme.listText)
                                    .font(Font.app.listItem)
                                    .listRowBackground(Color.theme.listBackground)
                                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                        Button {
                                            let maxCountOfTodosForToday: Int = settingsViewModel.settings.maxTodosForToday
                                            if todoViewModel.getTotalTodaysTodosCount() >= maxCountOfTodosForToday {
                                                    showErrorMessage = true
                                            } else {
                                                todoViewModel.addRecurringTaskAsTodoForToday(todaysTask)
                                            }
                                        } label: {
                                            Label("Add to Today", systemImage: "plus.square")
                                        }
                                        .tint(.green)
                                        .accessibilityIdentifier("AddRecurringTaskAsTodayTodoButton")
                                    }
                            }
                        }
                        .background(Color.background)
                    }
                    
                    Spacer()
                    
                    let defaultEstimatedTime: Int64  = Int64(settingsViewModel.settings.defaultTimeForEnergyLevelCalculation)
                    let totalEstimatedTime: Int64 = Int64(todoViewModel.getTotalEstimatedTime(defaultEstimatedTime: defaultEstimatedTime))
                    if totalEstimatedTime > 0 {
                        Section {
                            VStack {
                                
                                let maxEstimatedTime: Int64 = EnergyManager.getMaxEstimatedTime(energyLevel: energyLevel)
                                
                                Text("\(Localization.labels.estimatedTime): \(totalEstimatedTime)\(Localization.labels.estimatedTimeUnit).")
                                    .font(Font.app.normal)
                                    .foregroundColor(totalEstimatedTime > maxEstimatedTime ? Color.theme.red : Color.theme.primary)
                                    .fontWeight(totalEstimatedTime > maxEstimatedTime ? .bold : .regular)
                                    .padding(.top, 14)
                                    .padding(.bottom, 14)
                                HStack {
                                    Text(Localization.messages.energyLevelLow)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                    
                                    Text(Localization.messages.energyLevel)
                                    
                                    Spacer()
                                    
                                    Text(Localization.messages.energyLevelHigh)
                                        .multilineTextAlignment(.trailing)
                                }
                                .font(Font.app.tiny)
                                .padding(.horizontal,64)
                                
                                Slider(value: $energyLevel, in: 1...3, step: 1)
                                    .padding(.horizontal,64)
                                    .accentColor(Color.theme.accent)
                            }
                        }
                        .padding(.bottom, 14)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .backgroundStyle()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    ClaraMenuView(settingsViewModel: settingsViewModel, todoViewModel: todoViewModel)
                }
                ToolbarItem(placement: .principal) {
                    Text(Localization.labels.titleToday)
                        .foregroundColor(Color.theme.primary)
                        .font(Font.app.title)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            todoViewModel.reorderTodayTodos()
                        }) {
                            Image(systemName: "arrow.clockwise")
                        }
                        .accessibilityIdentifier("ReorderTodaysTodosButton")
                        Button(action: {
                            let maxCountOfTodosForToday: Int = settingsViewModel.settings.maxTodosForToday
                            if todoViewModel.getTotalTodaysTodosCount() >= maxCountOfTodosForToday {
                                showErrorMessage = true
                            } else {
                                showingAddTodo = true
                            }
                        }) {
                            Image(systemName: "plus.circle")
                        }
                        .accessibilityIdentifier("AddTodayTodoButton")
                    }
                }
            }
            .sheet(item: $sharedTodoDetails) { wrapper in
                let text = wrapper.todo.fullTodoDescription
                ShareSheet(activityItems: [text])
            }
            .sheet(item: $selectedTodo) { todo in
                TodoFormView(todoViewModel: todoViewModel, addDays: nil, existingTodo: todo)
            }
            .sheet(isPresented: $showingAddTodo) {
                TodoTodayFormView(todoViewModel: todoViewModel)
            }
            .alert(isPresented: $showErrorMessage) {
                Alert(
                    title: Text(Localization.messages.limitExeeded),
                    message: Text(String(format: Localization.messages.limitExeededMessage, "\(settingsViewModel.settings.maxTodosForToday)")),
                    dismissButton: .default(Text(Localization.labels.ok))
                )
            }
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        todoViewModel.moveTodayTodos(from: source, to: destination)
    }
    
}
