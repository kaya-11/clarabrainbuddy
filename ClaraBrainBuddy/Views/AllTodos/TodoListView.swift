//
//  Views/AllTodos/TodoListView.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//


import SwiftUI

struct TodoListView: View {
    
    @ObservedObject var todoViewModel : TodoViewModel = .shared
    @ObservedObject var settingsViewModel: SettingsViewModel = .shared
    
    @State private var showingAddTodo = false
    @State private var selectedTodo: Todo? = nil
    @State private var showErrorMessage = false
    
    @State private var sharedTodoDetails: SharedTodoDetailsWrapper? = nil
    @State private var sharedTodos: SharedTodosWrapper? = nil
    
    @State private var searchText = ""
    
    @Environment(\.managedObjectContext) private var context
     
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Todo.sortOrder, ascending: true)]
    ) private var todos: FetchedResults<Todo>
    
    var filteredTodos: [Todo] {
        if searchText.isEmpty {
            return Array(todos)
        } else {
            return todos.filter { todo in
                let titleMatches = todo.title.localizedCaseInsensitiveContains(searchText)
                let detailsMatches = (todo.details ?? "").localizedCaseInsensitiveContains(searchText)
                return titleMatches || detailsMatches
            }
        }
    }
    
    var body: some View {
      
        NavigationView {
            VStack {
                List {
                    ForEach(filteredTodos, id: \.objectID) { (todo: Todo) in
                        TodoListEntryView(
                            todoViewModel: todoViewModel,
                            todo: todo,
                            showAsSelectedForToday: todo.selectedForToday,
                            withSymbols: true,
                            showSymbols: settingsViewModel.settings.showSymbols,
                            showDueDate: true,
                            showResistance: settingsViewModel.settings.showResistanceInAllTodosView
                        )
                        .strikethrough(todo.isDone, color: Color.theme.primary)
                        .bold( todo.selectedForToday)
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
                                if todoViewModel.getTotalTodaysTodosCountNotDone() >= maxCountOfTodosForToday && !todo.selectedForToday {
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
                        .foregroundColor(StyleUtils.getTextColor(todo: todo, isSelectedForToday: todo.selectedForToday))
                        .listRowBackground(Color.theme.listBackground)
                        .font(Font.app.listItem)
                    }
                    .onMove(perform: move)
                    
                }
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
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
                    LimitExceededAlert(maxTodos: settingsViewModel.settings.maxTodosForToday).alert()
                }
                
                Spacer(minLength: 1)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .backgroundStyle()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    ClaraMenuView(settingsViewModel: settingsViewModel, todoViewModel: todoViewModel)
                }
                ToolbarItem(placement: .navigation ) {
                    let defaultEstimatedTime : Int = settingsViewModel.settings.defaultTimeForEnergyLevelCalculation
                    let (count, totalTime) = todoViewModel.calculateCompletedTodaysTodos(defaultEstimatedTime: defaultEstimatedTime)

                    CompletedTodosBadge(
                        todoViewModel: todoViewModel,
                        count: count,
                        totalTime: totalTime
                    )
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
