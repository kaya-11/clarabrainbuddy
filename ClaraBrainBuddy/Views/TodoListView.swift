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
    
    let title = NSLocalizedString("title.alltodos", comment: "All Todos")
    
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
                            .foregroundColor(Color.theme.listText)
                            .listRowBackground(Color.theme.listBackground)
                            .font(Font.app.listItem)
                    }
                    .onMove(perform: move)
                }
                .sheet(isPresented: $showingAddTodo) {
                    TodoFormView(todoViewModel: todoViewModel, existingTodo: nil)
                }
                .sheet(isPresented: $showingEditTodo) {
                    TodoFormView(todoViewModel: todoViewModel, existingTodo: selectedTodo)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .backgroundStyle()
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
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddTodo = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        todoViewModel.allTodos.move(fromOffsets: source, toOffset: destination)
        todoViewModel.updateTodos()
    }
}


