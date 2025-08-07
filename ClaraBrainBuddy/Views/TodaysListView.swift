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
    
    var recurringTasks: [RecurringTask] {
        let now = Date()
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: now)
        let day = calendar.component(.day, from: now)
        let lastDay = (calendar.range(of: .day, in: .month, for: now)?.upperBound ?? 32) - 1
        let dayToCompare = min(day, lastDay)
        let isEven = day.isMultiple(of: 2)
        let isWeekend = (weekday == 1) || (weekday == 7)
        
        return taskViewModel.allRecurringTasks.filter {
            switch $0.recurrenceRule {
            case .daily:
                return true
            case .weekly(let wd):
                return wd == weekday
            case .monthly(let d):
                return d == dayToCompare
            case .evenDays:
                return isEven && !isWeekend
            case .oddDays:
                return !isEven && !isWeekend
            }
            
        }.filter { task in
            !todoViewModel.isRecurringTaskInTodayTodos(task.id)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if todoViewModel.todayTodos.isEmpty && recurringTasks.isEmpty {
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
                        ForEach(todoViewModel.todayTodos, id: \.id) { todayTodo in
                            if let todo = todoViewModel.allTodos.first(where: { $0.id == todayTodo.todoId }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        if todo.isDone {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(Color.theme.green)
                                        } 
                                        Text(todo.title)
                                            .accessibilityValue(todo.isDone ? "done" : "active")
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    if let details = todo.details {
                                        if !details.isEmpty {
                                            Text(String(details.prefix(20)) + (details.count > 20 ? "..." : ""))
                                                .font(Font.app.tiny)
                                                .foregroundColor(Color.theme.secondary)
                                        }
                                    }
                                    
                                    if let dueDate = todo.dueDate {
                                        Text("\(Localization.labels.due): \(dueDate, formatter: StyleUtils.dateFormatter)")
                                            .font(Font.app.tiny)
                                            .foregroundColor(Color.theme.secondary)
                                    }
                                    
                                    let resistance = todo.resistance != nil ? todo.resistance! : 0
                                    if (1...10).contains(resistance) {
                                        HStack {
                                            ForEach(1...resistance, id: \.self) { value in
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
                                .strikethrough(todo.isDone, color: Color.theme.primary)
                                .italic(todo.isDone)
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
                            ForEach(recurringTasks, id: \.id) { todaysTask in
                                Text(todaysTask.title)
                                    .foregroundColor(Color.theme.listText)
                                    .font(Font.app.listItem)
                                    .listRowBackground(Color.theme.listBackground)
                                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                        Button {
                                            let maxCountOfTodosForToday: Int = settingsViewModel.settings.maxTodosForToday
                                            if todoViewModel.todayTodos.count >= maxCountOfTodosForToday {
                                                showErrorMessage = true
                                            } else {
                                                todoViewModel.addRecurringTaskAsTodoForToday(todaysTask)
                                            }
                                        } label: {
                                            Label("Add to Today", systemImage: "plus.square")
                                        }.tint(.green)
                                    }
                            }
                        }
                        .background(Color.background)
                    }
                    
                    Spacer()
                    
                    let defaultEstimatedTime = settingsViewModel.settings.defaultTimeForEnergyLevelCalculation
                    let totalEstimatedTime = todoViewModel.getTotalEstimatedTime(defaultEstimatedTime: defaultEstimatedTime)
                    if totalEstimatedTime > 0 {
                        Section {
                            VStack {
                                
                                let maxEstimatedTime = EnergyManager.getMaxEstimatedTime(energyLevel: energyLevel)
                                
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
                            if todoViewModel.todayTodos.count >= maxCountOfTodosForToday {
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
                let text = wrapper.todo.getDetails()
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
