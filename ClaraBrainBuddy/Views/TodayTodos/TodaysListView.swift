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
    
    @State private var sharedTodos: SharedTodosWrapper? = nil
    
    @State private var energyLevel: Float = EnergyManager.EnergyLevel.medium.rawValue
    
    @State private var showingInfo = false
    
    @State private var eventProvider: EventProvider = RealEventProvider()
    @State private var todayEvents: [EKEvent] = []
    
    @Environment(\.managedObjectContext) private var context
     
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \TodayTodo.sortOrder, ascending: true),
            NSSortDescriptor(keyPath: \TodayTodo.updatedAt, ascending: true)
        ]
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
            
            VStack (spacing: 0) {
                
                GeometryReader { geo in
                
                    VStack(spacing: 0) {
                        
                        if todayTodos.isEmpty && recurringTasks.isEmpty {
                            Text(Localization.labels.noTodosToday)
                                .foregroundColor(Color.theme.primary)
                                .font(Font.app.header)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 60)
                        } else {
                            List {
                                
                                Text("\(Localization.labels.todosPickedForToday):")
                                    .foregroundColor(Color.theme.primary)
                                    .font(Font.app.header)
                                    .textCase(.none)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .moveDisabled(true)
                                    .deleteDisabled(true)
                                    .selectionDisabled(true)
                                
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
                                    .onDrag {
                                        NSItemProvider(object: String(todo.objectID.uriRepresentation().absoluteString) as NSString)
                                    } preview: {
                                        Text(TodoUtils.getShortenedTitle(todo, maxLength: 30))
                                            .font(Font.app.tiny)
                                            .lineLimit(1)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
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
                                        .tint(Color.theme.graybrown)
                                        .accessibilityIdentifier("RemoveFromTodaysTodos")
                                        
                                        Button(role: .destructive) {
                                            todoViewModel.deleteTodo(todo)
                                        } label: {
                                            Label(Localization.labels.delete, systemImage: "trash")
                                        }
                                        .tint(Color.theme.red)
                                        .accessibilityIdentifier("TodaysTodosDeleteTodo")
                                        
                                    }
                                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                        
                                        Button {
                                            todoViewModel.setToDone(todayTodo)
                                            DeviceFeedback.vibrateTwice()
                                        } label: {
                                            Label(Localization.labels.done, systemImage: "checkmark.square")
                                        }
                                        .tint(Color.theme.green)
                                        .accessibilityIdentifier("MarkAsDoneButton")
                                        
                                        Button {
                                            selectedTodo = todo
                                        } label: {
                                            Label(Localization.labels.edit, systemImage: "pencil")
                                        }
                                        .tint(Color.theme.brown)
                                        
                                        Button {
                                            sharedTodos = SharedTodosWrapper(todos: [todo])
                                        } label: {
                                            Label(Localization.labels.shareDetails, systemImage: "square.and.arrow.up")
                                        }
                                        .tint(Color.theme.mauve)
                                        
                                        
                                        Button {
                                            todoViewModel.cloneTodo(todo: todo)
                                        } label: {
                                            Label(Localization.labels.clone, systemImage: "plus.square.on.square")
                                        }
                                        .tint(Color.theme.darkerBrown)
                                        
                                        Button {
                                            sharedTodoDetails = SharedTodoDetailsWrapper(todo: todo)
                                        } label: {
                                            Label(Localization.labels.copy, systemImage: "doc.on.doc")
                                        }
                                        .tint(Color.theme.graybrown)
                                        
                                    }
                                    .foregroundColor(StyleUtils.getTextColorForToday(todo: todo, isSelectedForToday: false))
                                    .listRowBackground(Color.clear)
                                    .font(Font.app.listItem)
                                }
                                .onMove(perform: move)
                            }
                            .accessibilityIdentifier("TodaysListContainer")
                            .background(Color.clear)
                            .frame(height: recurringTasks.isEmpty ? geo.size.height - 130 : geo.size.height *  0.618)
                            
                            Spacer(minLength: 10)
                            
                            VStack (spacing: 0) {
                                
                                if (!recurringTasks.isEmpty) {
                                    
                                    Text("\(Localization.labels.recurringTasksToday):")
                                        .foregroundColor(Color.theme.primary)
                                        .font(Font.app.header)
                                        .textCase(.none)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 30)
                                    
                                    List {
                                        
                                        ForEach(recurringTasks, id: \.objectID) { (todaysTask: RecurringTask) in
                                            let title = todaysTask.title
                                            Text(title)
                                                .foregroundColor(Color.theme.surfaceGlassTextColor)
                                                .font(Font.app.listItem)
                                                .listRowBackground(Color.clear)
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
                                                    .tint(Color.theme.green)
                                                    .accessibilityIdentifier("AddRecurringTaskAsTodayTodoButton")
                                                }
                                        }
                                    }
                                    .contentMargins(.top, 0, for: .scrollContent)
                                    .padding(.top, 20)
                                    .background(Color.clear)
                                    
                                }
                            
                                Spacer(minLength: 10)
                                
                                TimeBudgetView(
                                    todoViewModel: todoViewModel,
                                    settingsViewModel: settingsViewModel,
                                    energyLevel: $energyLevel
                                )
                            }
                            .frame(height: recurringTasks.isEmpty ? 130 : geo.size.height * 0.382)
                            
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .appTheme()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        ClaraMenuView(settingsViewModel: settingsViewModel, todoViewModel: todoViewModel)
                        
                        let defaultEstimatedTime : Int = settingsViewModel.settings.defaultTimeForEnergyLevelCalculation
                        let (count, totalTime) = todoViewModel.calculateCompletedTodaysTodos(defaultEstimatedTime: defaultEstimatedTime)
                        
                        CompletedTodosBadge(
                            todoViewModel: todoViewModel,
                            count: count,
                            totalTime: totalTime
                        )
                    }
                    .foregroundColor(Color.theme.primary)
                }
                ToolbarItem(placement: .principal) {
                    Text(Localization.labels.titleToday)
                        .foregroundColor(Color.theme.primary)
                        .font(Font.app.header)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if !todayEvents.isEmpty {
                            Button(action: {
                                showingCalenderView = true
                            }) {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(Color.theme.primary)
                            }
                            .accessibilityIdentifier("TodayEventsBellButton")
                        }
                        Button(action: {
                            todoViewModel.reorderTodayTodos(defaultEstimatedTime: settingsViewModel.settings.defaultTimeForEnergyLevelCalculation)
                        }) {
                            CombinedImageView(imageMain: "chart.bar.horizontal.page", imageSmall: "arrow.up.arrow.down")
                                .foregroundColor(Color.theme.primary)
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
                                .foregroundColor(Color.theme.primary)
                        }
                        .accessibilityIdentifier("AddTodayTodoButton")
                    }
                }
            }
            .sheet(item: $sharedTodos) { wrapper in
                let todos : [Todo] = wrapper.todos
                let dateString = StyleUtils.dateTimeFormatter.string(from: Date())
                let filename = "\(Localization.filename.exportTodo)_\(dateString)"
                let url : URL = ImportExportUtils.exportListOfTodosToJSONFile(todos: todos, fileName: filename)
                if (FileManager.default.fileExists(atPath: url.path)) {
                    ShareSheet(activityItems: [url])
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
                                 eventProvider: FakeEventProvider(),
                                 onlyToday: true)
                } else {
                    CalendarView(todoViewModel: todoViewModel,
                                 eventProvider: RealEventProvider(),
                                 onlyToday: true)
                }
            }
            .onChange(of: todayTodos.count) {
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
