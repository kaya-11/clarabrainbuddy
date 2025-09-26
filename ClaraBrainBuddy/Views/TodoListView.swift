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
    @State private var sharedTodoDetails: SharedTodoDetailsWrapper? = nil
    @State private var sharedTodos: SharedTodosWrapper? = nil
    
    @Environment(\.managedObjectContext) private var context
     
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Todo.sortOrder, ascending: true)]
    ) private var todos: FetchedResults<Todo>
    
    init(todoViewModel: TodoViewModel, settingsViewModel: SettingsViewModel) {
        self.todoViewModel = todoViewModel
        self.settingsViewModel = settingsViewModel
    }
    
    var body: some View {
      
        NavigationView {
            VStack {
                List {
                    ForEach(todos, id: \.objectID) { (todo: Todo) in
                        let isSelectedForToday: Bool = todo.selectedForToday
                        let isDone: Bool = todo.isDone
                        let title: String = todo.title
                        let details: String = todo.details ?? ""
                        let dueDate: Date = todo.dueDate
                        let isOverdue: Bool = todo.isOverdue
                        let isDueSoon: Bool = todo.isDueSoon
                        let resistance: Int64 = todo.resistance
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                if isDone {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color.theme.green)
                                } else if isSelectedForToday {
                                    Text("🌀🐿️")
                                } else if isOverdue {
                                    Text("🦥")
                                } else if isDueSoon {
                                    Text("🐶")
                                }
                                Text(title + (todo.isOverdue && !isSelectedForToday ? " ‼️" : ""))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                           if !details.isEmpty {
                                Text(String(details.prefix(20)) + (details.count > 20 ? "..." : ""))
                                    .font(Font.app.tiny)
                                    .foregroundColor(Color.theme.secondary)
                            }
                            
                            Text("\(Localization.labels.due): \(dueDate, formatter: StyleUtils.dateFormatter)")
                                .font(Font.app.tiny)
                                .foregroundColor(Color.theme.secondary)
                            
                            if (1...10).contains(Int(resistance)) {
                                HStack {
                                    ForEach(1...Int(resistance), id: \.self) { value in
                                        Image(systemName: "mountain.2")
                                            .foregroundColor(StyleUtils.iconFontColorForLevels(for: value))
                                            .imageScale(.small)
                                            .font(StyleUtils.iconFontSizeForLevels(for: value))
                                    }
                                }
                            }
                        }
                        .strikethrough(isDone, color: Color.theme.primary)
                        .bold(isSelectedForToday)
                        .onTapGesture(count: 2) {
                            selectedTodo = todo
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        
                            Button(role: .destructive) {
                                todoViewModel.deleteTodo(todo)
                            } label: {
                                Label(Localization.labels.delete, systemImage: "trash")
                            }
                            .tint(.red)
                            .accessibilityIdentifier("TodoListDeleteTodo")
                            
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            
                            Button {
                                let maxCountOfTodosForToday: Int = settingsViewModel.settings.maxTodosForToday
                                if todoViewModel.getTotalTodaysTodosCount() >= maxCountOfTodosForToday && !isSelectedForToday {
                                    showErrorMessage = true
                                } else {
                                    todoViewModel.selectForToday(todo)
                                }
                            } label: {
                                Label(Localization.labels.today, systemImage: "calendar")
                            }
                            .tint(.blue)
                            .accessibilityIdentifier("MarkForToday")
                            
                            Button {
                                selectedTodo = todo
                            } label: {
                                Label(Localization.labels.edit, systemImage: "pencil")
                            }
                            .tint(.green)
                            .accessibilityIdentifier("TodoListViewEditTodo")

                            Button {
                                sharedTodos = SharedTodosWrapper(todos: [todo])
                            } label: {
                                Label(Localization.labels.shareDetails, systemImage: "square.and.arrow.up")
                            }
                            .tint(.mint)
                            
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
                        .foregroundColor(StyleUtils.getTextColor(todo: todo, isSelectedForToday: isSelectedForToday))
                        .listRowBackground(Color.theme.listBackground)
                        .font(Font.app.listItem)
                    }
                    .onMove(perform: move)
                }
                .sheet(isPresented: $showingAddTodo) {
                    TodoFormView(todoViewModel: todoViewModel, addDays: settingsViewModel.settings.daysAddedForDefaultDueDate, existingTodo: nil)
                }
                .sheet(item: $sharedTodos) { wrapper in
                    let todos : [Todo] = wrapper.todos
                    let url : URL = ImportExportUtils.exportListOfTodosToJSONFile(todos: todos, fileName: "clara_todo.json")
                    if (FileManager.default.fileExists(atPath: url.path)) {
                        ShareSheet(activityItems: [url])
                    }
                }
                .sheet(item: $sharedTodoDetails) { wrapper in
                    let text = wrapper.todo.fullTodoDescription
                    ShareSheet(activityItems: [text])
                }
                .sheet(item: $selectedTodo) { todo in
                    TodoFormView(todoViewModel: todoViewModel, addDays: nil, existingTodo: todo).accessibilityIdentifier("TodoFormView")
                    
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
                    }.accessibilityIdentifier("AddTodoButton")
                }
            }
            .toolbarBackground(Color.theme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        todoViewModel.moveTodo(from: source, to: destination)
    }
    
}
