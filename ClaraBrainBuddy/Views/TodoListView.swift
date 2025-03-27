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
    let editLabel = NSLocalizedString("edit.label", comment: "Edit")
    let deleteLabel = NSLocalizedString("delete.label", comment: "Delete")
    let todayLabel = NSLocalizedString("today.label", comment: "Today")
    
    var body: some View {
      
        NavigationView {
            VStack {
                List {
                    ForEach(todoViewModel.allTodos, id: \.self) { todo in
                        let isSelectedForToday = todo.isSelectedForToday
                        Text(todo.title)
                            .strikethrough(todo.isDone, color: Color.theme.primary)
                            .italic(isSelectedForToday)
                            .bold(isSelectedForToday)
                            .onTapGesture(count: 2) {
                                selectedTodo = todo
                                showingEditTodo = true
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    todoViewModel.deleteTodo(todo)
                                } label: {
                                    Label(deleteLabel, systemImage: "trash")
                                }.tint(.red)
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    todoViewModel.selectForToday(todo)
                                } label: {
                                    Label(todayLabel, systemImage: "calendar")
                                }.tint(.blue)
                                Button {
                                    selectedTodo = todo
                                    showingEditTodo = true
                                } label: {
                                    Label(editLabel, systemImage: "pencil")
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
                    Button(action: {
                        showingAddTodo = true
                    }) {
                        Image(systemName: "plus.circle")
                    }
                }
            }
            .toolbarBackground(Color.theme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        todoViewModel.allTodos.move(fromOffsets: source, toOffset: destination)
        todoViewModel.updateTodos()
    }
}


