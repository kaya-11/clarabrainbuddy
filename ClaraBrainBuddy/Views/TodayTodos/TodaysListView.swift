//
//  Views/TodayTodos/TodaysListView.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//

import SwiftUI
import EventKit

struct TodaysListView: View {
    
    @ObservedObject var todoViewModel: TodoViewModel = .shared
    @ObservedObject var taskViewModel: TaskViewModel = .shared
    @ObservedObject var settingsViewModel: SettingsViewModel = .shared
    
    @State private var showingAddTodo = false
    @State private var showingCalenderView = false
    @State private var selectedTodo: Todo? = nil
    @State private var showErrorMessage = false
    @State private var sharedTodoDetails: SharedTodoDetailsWrapper? = nil
    @State private var energyLevel: Float = EnergyManager.EnergyLevel.medium.rawValue
    
    @State private var showingInfo = false
    
    @State private var eventProvider: EventProvider = RealEventProvider()
    @State private var todayEvents: [EKEvent] = []
    
    @Environment(\.managedObjectContext) private var context
     
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TodayTodo.sortOrder, ascending: true)]
    ) private var todayTodos: FetchedResults<TodayTodo>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \RecurringTask.sortOrder, ascending: true)]
    ) private var tasks: FetchedResults<RecurringTask>
            
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
                                
                            TodoListEntryView(
                                todoViewModel: todoViewModel,
                                todo: todo,
                                showAsSelectedForToday: true,
                                isInTodayView: true,
                                showSymbols: settingsViewModel.settings.showSymbols,
                                showDueDate: settingsViewModel.settings.showDueDateInSchedule,
                                showResistance: settingsViewModel.settings.showResistanceInTodayView
                            )
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
                                    todoViewModel.setToDone(todayTodo)
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
                            .foregroundColor(StyleUtils.getTextColorForToday(todo: todo, isSelectedForToday: false))
                            .listRowBackground(Color.theme.listBackground)
                            .font(Font.app.listItem)
                        }
                        .onMove(perform: move)
                    }
                    .background(Color.theme.background)
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
                                            if todoViewModel.getTotalTodaysTodosCountNotDone() >= maxCountOfTodosForToday {
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
                    
                    TimeBudgetView(
                        todoViewModel: todoViewModel,
                        settingsViewModel: settingsViewModel,
                        energyLevel: $energyLevel
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .backgroundStyle()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    ClaraMenuView(settingsViewModel: settingsViewModel, todoViewModel: todoViewModel)
                }
                ToolbarItem(placement: .navigation ) {
                    let defaultEstimatedTime : Int = settingsViewModel.settings.defaultTimeForEnergyLevelCalculation
                    let (count, totalTime) = todoViewModel.calculateCompletedTodaysTodos(defaultEstimatedTime: defaultEstimatedTime)

                    CompletedTodosBadge(
                        todoViewModel: todoViewModel,
                        count: count,
                        totalTime: totalTime
                    )
                }
                ToolbarItem(placement: .principal) {
                    Text(Localization.labels.titleToday)
                        .foregroundColor(Color.theme.primary)
                        .font(Font.app.title)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if !todayEvents.isEmpty {
                            Button(action: {
                                showingCalenderView = true
                            }) {
                                Image(systemName: "bell.fill")
                            }
                            .accessibilityIdentifier("TodayEventsBellButton")
                        }
                        Button(action: {
                            todoViewModel.reorderTodayTodos()
                        }) {
                            Image(systemName: "arrow.clockwise")
                        }
                        .accessibilityIdentifier("ReorderTodaysTodosButton")
                        Button(action: {
                            let maxCountOfTodosForToday: Int = settingsViewModel.settings.maxTodosForToday
                            if todoViewModel.getTotalTodaysTodosCountNotDone() >= maxCountOfTodosForToday {
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
            .sheet(isPresented: $showingCalenderView) {
                if CommandLine.arguments.contains("UITestMode") {
                    CalendarView(todoViewModel: todoViewModel,
                                 eventProvider: FakeEventProvider())
                } else {
                    CalendarView(todoViewModel: todoViewModel,
                                 eventProvider: RealEventProvider())
                }
            }
            .onChange(of: todayTodos.count) { _ in
                eventProvider.fetchTodayEvents { events in
                    self.todayEvents = events.filter { event in
                        !todoViewModel.eventAlreadyExistsAsTodo(event)
                    }
                }
            }
            .alert(isPresented: $showErrorMessage) {
                LimitExceededAlert(maxTodos: settingsViewModel.settings.maxTodosForToday).alert()
            }
        }
        .onAppear() {
            eventProvider.fetchTodayEvents { events in
                    self.todayEvents = events.filter { event in
                        !todoViewModel.eventAlreadyExistsAsTodo(event)
                    }
            }
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        todoViewModel.moveTodayTodos(from: source, to: destination)
    }

}
