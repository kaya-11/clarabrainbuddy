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

    @State private var showingAddTodo = false
    
    @State private var showingEditTodo = false
    @State private var selectedTodo: Todo? = nil
    
    @State private var energyLevel: Float = EnergyLevel.medium.rawValue
    
    let title = NSLocalizedString("title.today", comment: "Today")
    
    let noTodosTodayMsg = NSLocalizedString("message.no.todos.today", comment: "No todo's today")
    let todosPickedForTodayMsg = NSLocalizedString("message.todos.picked.today", comment: "Todo's for today")
    let recurringTasksTodayMsg = NSLocalizedString("message.recurring.tasks.today", comment: "Recurring Task's today")
    
    let estimatedTimeMsg = NSLocalizedString("message.estimated.time", comment: "Estimeted time")
    let estimatedTimeUnitMsg = NSLocalizedString("message.estimated.time.unit", comment: "min.")
    
    let energyLevelMsg = NSLocalizedString("message.energy.level", comment: "Energy Level")
    let energyLevelLowMsg = NSLocalizedString("message.energy.level.low", comment: "Energy Level")
    let energyLevelMediumMsg = NSLocalizedString("message.energy.level.medium", comment: "Energy Level")
    let energyLevelHighMsg = NSLocalizedString("message.energy.level.high", comment: "Energy Level")
    

    var recurringTasks: [RecurringTask] {
        let now = Date()
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: now)
        let day = calendar.component(.day, from: now)
        let lastDay = (calendar.range(of: .day, in: .month, for: now)?.upperBound ?? 32) - 1
        let dayToCompare = min(day, lastDay)
        
        return taskViewModel.allRecurringTasks.filter {
            switch $0.recurrenceRule {
            case .daily:
                return true
            case .weekly(let wd):
                return wd == weekday
            case .monthly(let d):
                return d == dayToCompare
            }
        }
    }
        
    
    var totalEstimatedTime: Int {
        todoViewModel.todayTodos.compactMap { todayTodo in
            if let todo = todoViewModel.allTodos.first(where: { $0.id == todayTodo.todoId }) {
                return todo.isDone ? nil : todo.estimatedTime
            }
            return nil
        }.reduce(0, +)
    }

    var maxEstimatedTime: Int {
        switch energyLevel {
            case EnergyLevel.low.rawValue:
                    return 100
            case EnergyLevel.medium.rawValue:
                    return 150
            case EnergyLevel.high.rawValue:
                    return 200
            default:
                return 0
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if todoViewModel.todayTodos.isEmpty && recurringTasks.isEmpty {
                    Text(noTodosTodayMsg)
                        .foregroundColor(Color.theme.primary)
                        .font(.title)
                        .padding()
                } else {
                    
                    Text("\(todosPickedForTodayMsg):")
                            .foregroundColor(Color.theme.primary)
                            .font(Font.app.listHeader)
                            .textCase(.none)
                            .padding(.top, 28)
                            .padding(.bottom, -1)
                    
                    List {
                        ForEach(todoViewModel.todayTodos, id: \.id) { todayTodo in
                            if let todo = todoViewModel.allTodos.first(where: { $0.id == todayTodo.todoId }) {
                                Text(todo.title)
                                    .onTapGesture(count: 2) {
                                        selectedTodo = todo
                                        showingEditTodo = true
                                    }
                                    .strikethrough(todo.isDone, color: Color.theme.primary)
                                    .italic(todo.isDone)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            todoViewModel.deselectForToday(todo)
                                        } label: {
                                            Label("Remove", systemImage: "minus.square")
                                        }.tint(.orange)
                                        Button(role: .destructive) {
                                            todoViewModel.deleteTodo(todo)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }.tint(.red)
                                    }
                                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                        Button {
                                            todoViewModel.setToDone(todo)
                                        } label: {
                                            Label("Done", systemImage: "checkmark.square")
                                        }.tint(.blue)
                                        Button {
                                            selectedTodo = todo
                                            showingEditTodo = true
                                        } label: {
                                            Label("Done", systemImage: "pencil")
                                        }.tint(.green)
                                    }
                                    .foregroundColor(Color.theme.listText)
                                    .listRowBackground(Color.theme.listBackground)
                                    .font(Font.app.listItem)
                            }
                        }
                        .onMove(perform: move)
                    }
                    .background(Color.background)
                    .frame(width: 400, height: 300)
                    .padding(.top, -1)
                    .padding(.bottom, -1)
                    
                    Text("\(recurringTasksTodayMsg):")
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
                                            todoViewModel.addRecurringTaskAsTodoForToday(todaysTask)
                                        } label: {
                                            Label("Add to Today", systemImage: "plus.square")
                                        }.tint(.green)
                                }
                        }
                    }
                    .background(Color.background)
                    
                    if totalEstimatedTime > 0 {
                        Section {
                            VStack {
                                
                                Text("\(estimatedTimeMsg): \(totalEstimatedTime)\(estimatedTimeUnitMsg).")
                                    .font(Font.app.normal)
                                    .foregroundColor(totalEstimatedTime > maxEstimatedTime ? Color.theme.red : Color.theme.primary)
                                    .fontWeight(totalEstimatedTime > maxEstimatedTime ? .bold : .regular)
                                    .padding(.top, 14)
                                    .padding(.bottom, 14)
                                HStack {
                                    Text(energyLevelLowMsg)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                    
                                    Text(energyLevelMsg)
                                    
                                    Spacer()
                                    
                                    Text(energyLevelHighMsg)
                                        .multilineTextAlignment(.trailing)
                                }
                                .font(Font.app.tiny)
                                .padding(.horizontal,64)
                                
                                Slider(value: $energyLevel, in: 1...3, step: 1)
                                    .padding(.horizontal,64)
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
                    Image("Clara")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 55, height: 55)
                }
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .foregroundColor(Color.theme.primary)
                        .font(Font.app.title)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddTodo = true
                    }) {
                        Image(systemName: "plus.circle")
                    }
                }
            }
            .sheet(isPresented: $showingEditTodo) {
                TodoFormView(todoViewModel: todoViewModel, existingTodo: selectedTodo)
            }
            .sheet(isPresented: $showingAddTodo) {
                TodoTodayFormView(todoViewModel: todoViewModel)
            }
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        todoViewModel.reorderTodayTodos(from: source, to: destination)
    }
    
}
