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
    
    @State private var selectedTodo: Todo? = nil
    
    @State private var energyLevel: Float = EnergyManager.EnergyLevel.medium.rawValue
    
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
                                Text(todo.title)
                                    .onTapGesture(count: 2) {
                                        selectedTodo = todo
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
                                            DeviceFeedback.vibrateTwice()
                                        } label: {
                                            Label("Done", systemImage: "checkmark.square")
                                        }.tint(.blue)
                                        Button {
                                            selectedTodo = todo
                                        } label: {
                                            Label("Done", systemImage: "pencil")
                                        }.tint(.green)
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
                                            todoViewModel.addRecurringTaskAsTodoForToday(todaysTask)
                                        } label: {
                                            Label("Add to Today", systemImage: "plus.square")
                                        }.tint(.green)
                                    }
                            }
                        }
                        .background(Color.background)
                    }
                    
                    Spacer()
                    
                    let totalEstimatedTime = todoViewModel.getTotalEstimatedTime()
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
                    Image("Clara")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 55, height: 55)
                }
                ToolbarItem(placement: .principal) {
                    Text(Localization.labels.titleToday)
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
            .sheet(item: $selectedTodo) { todo in
                TodoFormView(todoViewModel: todoViewModel, existingTodo: todo)
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
