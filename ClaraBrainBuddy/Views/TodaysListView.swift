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

    @State private var showingEditTodo = false    
    @State private var selectedTodo: Todo? = nil
    
    let todayTitle = NSLocalizedString("title.today", comment: "No todo's today")
    
    let noTodosTodayMsg = NSLocalizedString("message.no.todos.today", comment: "No todo's today")
    let todosPirckedForTodayMsg = NSLocalizedString("message.todos.picked.today", comment: "Todo's for today")
    let recurringTasksTodayMsg = NSLocalizedString("message.recurring.tasks.today", comment: "Recurring Task's today")
    
    let estimatedTimeMsg = NSLocalizedString("message.estimated.time", comment: "Estimeted time")
    let estimatedTimeUnitMsg = NSLocalizedString("message.estimated.time.unit", comment: "min.")

    var taskList : [RecurringTask] {
        let currentDate = Date()
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: currentDate)
        let dayOfMonth = calendar.component(.day, from: currentDate)
        let rangeOfDays = calendar.range(of: .day, in: .month, for: currentDate)
        let lastDayOfMonth = (rangeOfDays?.upperBound ?? 32)-1
        let dayToCompare = min(dayOfMonth, lastDayOfMonth)
        return taskViewModel.allRecurringTasks.filter { $0.recurrenceRule == .daily || $0.recurrenceRule == .weekly(weekday: dayOfWeek) || $0.recurrenceRule == .monthly(day : dayToCompare)}
    }
    var totalEstimatedTime: Int {
        todoViewModel.todayTodos.compactMap { todayTodo in
            todoViewModel.allTodos.first(where: { $0.id == todayTodo.todoId })?.estimatedTime
        }.reduce(0, +)
    }

    var body: some View {
        NavigationView {
            VStack {
                if todoViewModel.todayTodos.isEmpty && taskList.isEmpty {
                    Text(noTodosTodayMsg)
                        .foregroundColor(Colors.primary)
                        .font(.headline)
                        .padding()
                } else {
                    
                    Text("\(todosPirckedForTodayMsg):")
                        .foregroundColor(Colors.primary)
                        .font(.headline)
                        .padding()
                    
                    List {
                        ForEach(todoViewModel.todayTodos, id: \.id) { todayTodo in
                            if let todo = todoViewModel.allTodos.first(where: { $0.id == todayTodo.todoId }) {
                                Text(todo.title)
                                    .onTapGesture(count: 2) {
                                        selectedTodo = todo
                                        showingEditTodo = true
                                    }
                                    .strikethrough(todo.isDone, color: .gray)
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
                                    .foregroundColor(Colors.listText)
                                    .listRowBackground(Colors.listBackground)
                            }
                        }
                        .onMove(perform: move)
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.background)
                    .padding(10)
                    
                    Text("\(recurringTasksTodayMsg):")
                        .foregroundColor(Colors.primary)
                        .font(.headline)
                    
                    List {
                        ForEach(taskList, id: \.id) { todaysTask in
                            Text(todaysTask.title)
                                .foregroundColor(Colors.listText)
                                .listRowBackground(Colors.listBackground)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.background)
                    
                    if totalEstimatedTime > 0 {
                        Text("\(estimatedTimeMsg): \(totalEstimatedTime) \(estimatedTimeUnitMsg).")
                            .font(.title2)
                            .foregroundColor(totalEstimatedTime > 210 ? Color("RedColor") : Color("PrimaryColor"))
                            .fontWeight(totalEstimatedTime > 210 ? .bold : .regular)
                            .padding(.bottom, 28)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accentColor(Colors.accent)
            .backgroundStyle()
            .navigationTitle(todayTitle)
            .navigationBarItems(
                leading: EditButton())
            .sheet(isPresented: $showingEditTodo) {
                           TodoFormView(todoViewModel: todoViewModel, existingTodo: selectedTodo)
            }
        }
        
    }
    
    func move(from source: IndexSet, to destination: Int) {
        todoViewModel.reorderTodayTodos(from: source, to: destination)
    }
    
}
