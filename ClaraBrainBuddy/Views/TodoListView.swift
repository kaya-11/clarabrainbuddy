//
//  Views/TodoListView.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//


import SwiftUI

struct TodoListView: View {
    @ObservedObject var todoViewModel: TodoViewModel
    
    @State private var showingAddTodo = false
    
    @State private var showingEditTodo = false
    @State private var selectedTodo: Todo? = nil
    
    var body: some View {
      
        NavigationView {
            VStack {
                List {
                    ForEach(todoViewModel.allTodos, id: \.self) { todo in
                        Text(todo.title)
                            .strikethrough(todo.isDone, color: .primary)
                            .italic(todo.isSelectedForToday)
                            .onTapGesture(count: 2) {
                                selectedTodo = todo
                                showingEditTodo = true
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    todoViewModel.deleteTodo(todo)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }.tint(.red)
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    todoViewModel.selectForToday(todo)
                                } label: {
                                    Label("Today", systemImage: "calendar")
                                }.tint(.blue)
                                Button {
                                    selectedTodo = todo
                                    showingEditTodo = true
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }.tint(.green)
                            }
                            .foregroundColor(Colors.listText)
                            .listRowBackground(Colors.listBackground)
                    }
                    .onMove(perform: move)
                }
                .scrollContentBackground(.hidden) // Hide the default background
                .backgroundStyle()                // Apply your custom background style
                .navigationTitle("All Todos")
                .navigationBarItems(
                    leading: EditButton(),
                    trailing: Button(action: {
                        showingAddTodo = true
                    }) {
                        Image(systemName: "plus")
                    })
                .sheet(isPresented: $showingAddTodo) {
                    TodoFormView(todoViewModel: todoViewModel, existingTodo: nil)
                }
                .sheet(isPresented: $showingEditTodo) {
                    TodoFormView(todoViewModel: todoViewModel, existingTodo: selectedTodo)
                }
            }
            .backgroundStyle()
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        todoViewModel.allTodos.move(fromOffsets: source, toOffset: destination)
        todoViewModel.updateTodos()
    }
}


