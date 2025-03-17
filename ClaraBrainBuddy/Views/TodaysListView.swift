//
//  Views/DailyTodoView.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//

import SwiftUI

struct TodaysListView: View {
    @ObservedObject var todoViewModel: TodoViewModel
    
    @State private var showingEditTodo = false    
    @State private var selectedTodo: Todo? = nil
    
    var totalEstimatedTime: Int {
        todoViewModel.todayTodos.compactMap { todayTodo in
            todoViewModel.allTodos.first(where: { $0.id == todayTodo.todoId })?.estimatedTime
        }.reduce(0, +)
    }

    var body: some View {
        NavigationView {
            VStack {
                if todoViewModel.todayTodos.isEmpty {
                    Text("No todos for today")
                        .foregroundColor(.gray)
                        .font(.headline)
                        .padding()
                } else {
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
                            }
                        }
                        .onMove(perform: move)
                    }
                    .listStyle(PlainListStyle())
                    
                    if totalEstimatedTime > 0 {
                        Text("Estimated Time: \(totalEstimatedTime) min")
                            .font(.title2)
                            .foregroundColor(totalEstimatedTime > 210 ? .red : .primary)
                            .fontWeight(totalEstimatedTime > 210 ? .bold : .regular)
                            .padding(.bottom, 28)
                    }
                }
            }
            .navigationTitle("Today's Todos")
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
