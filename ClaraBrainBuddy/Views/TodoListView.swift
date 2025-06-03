//
//  Views/TodoListView.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//


import SwiftUI

struct TodoListView: View {
    
    @ObservedObject var todoViewModel: TodoViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel
    
    @State private var showingAddTodo = false
    @State private var selectedTodo: Todo? = nil
    @State private var showErrorMessage = false
    
    var body: some View {
      
        NavigationView {
            VStack {
                List {
                    ForEach(todoViewModel.allTodos, id: \.self) { todo in
                        let isSelectedForToday = todo.isSelectedForToday
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                if todo.isDone {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color.theme.green)
                                } else if isSelectedForToday {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(Color.theme.blue)
                                } else if todo.dueDate ?? Date() < StyleUtils.getDateSevenDaysBeforeNow() {
                                    Image(systemName: "stop.fill")
                                        .foregroundColor(Color.theme.red)
                                } else if todo.dueDate ?? Date() < StyleUtils.getDateThreeDaysFromNow() {
                                    Image(systemName: "triangle.fill")
                                        .foregroundColor(Color.theme.accent)
                                }
                                Text(todo.title)
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
                        .strikethrough(todo.isDone, color: Color.theme.primary)
                        .bold(isSelectedForToday)
                        .onTapGesture(count: 2) {
                            selectedTodo = todo
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        
                            Button(role: .destructive) {
                                todoViewModel.deleteTodo(todo)
                            } label: {
                                Label(Localization.labels.delete, systemImage: "trash")
                            }.tint(.red)
                            
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            
                            Button {
                                let maxCountOfTodosForToday: Int = settingsViewModel.settings.maxTodosForToday
                                if todoViewModel.todayTodos.count >= maxCountOfTodosForToday && !todo.isSelectedForToday {
                                    showErrorMessage = true
                                } else {
                                    todoViewModel.selectForToday(todo)
                                }
                            } label: {
                                Label(Localization.labels.today, systemImage: "calendar")
                            }
                            .tint(.blue)
                            
                            Button {
                                selectedTodo = todo
                            } label: {
                                Label(Localization.labels.edit, systemImage: "pencil")
                            }
                            .tint(.green)
                            
                            Button {
                                todoViewModel.cloneTodo(todo: todo)
                            } label: {
                                Label(Localization.labels.clone, systemImage: "doc.on.doc")
                            }
                            .tint(.gray)
                            
                        }
                        .foregroundColor(StyleUtils.getTextColor(todo: todo, isSelectedForToday: isSelectedForToday))
                        .listRowBackground(Color.theme.listBackground)
                        .font(Font.app.listItem)
                    }
                    .onMove(perform: move)
                }
                .sheet(isPresented: $showingAddTodo) {
                    TodoFormView(todoViewModel: todoViewModel, addDays: settingsViewModel.settings.daysAddedForDefaultDueDate,
                                 existingTodo: nil)
                }
                .sheet(item: $selectedTodo) { todo in
                    TodoFormView(todoViewModel: todoViewModel, addDays: nil, existingTodo: todo)
                }
                .alert(isPresented: $showErrorMessage) {
                    Alert(
                        title: Text(Localization.messages.limitExeeded),
                        message: Text(String(format: Localization.messages.limitExeededMessage, "\(settingsViewModel.settings.maxTodosForToday)")),
                        dismissButton: .default(Text(Localization.labels.ok))
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .backgroundStyle()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    ClaraMenuView(settingsViewModel: settingsViewModel, todoViewModel: todoViewModel)
                }
                ToolbarItem(placement: .principal) {
                    Text(Localization.labels.titleAllTodos)
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
