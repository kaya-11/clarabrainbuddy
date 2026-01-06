//
//  Views/common/TodoListCoreView.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 06.01.26.
//

import SwiftUI
import UniformTypeIdentifiers

struct TodoListCoreView: View {
    @ObservedObject var todoViewModel: TodoViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel
    @Binding var selectedTodo: Todo?
    @Binding var showErrorMessage: Bool
    @Binding var sharedTodoDetails: SharedTodoDetailsWrapper?
    @Binding var sharedTodos: SharedTodosWrapper?
    @Binding var showingAddTodo: Bool
    
    @FetchRequest var filteredTodos: FetchedResults<Todo>
    let category: Category?
    
    init(
        predicate: NSPredicate,
        category: Category?,
        todoViewModel: TodoViewModel,
        settingsViewModel: SettingsViewModel,
        selectedTodo: Binding<Todo?>,
        showErrorMessage: Binding<Bool>,
        sharedTodoDetails: Binding<SharedTodoDetailsWrapper?>,
        sharedTodos: Binding<SharedTodosWrapper?>,
        showingAddTodo: Binding<Bool>
    ) {
        self.category = category
        self.todoViewModel = todoViewModel
        self.settingsViewModel = settingsViewModel
        self._selectedTodo = selectedTodo
        self._showErrorMessage = showErrorMessage
        self._sharedTodoDetails = sharedTodoDetails
        self._sharedTodos = sharedTodos
        self._showingAddTodo = showingAddTodo

        self._filteredTodos = FetchRequest(
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Todo.sortOrder, ascending: true),
                NSSortDescriptor(keyPath: \Todo.updatedAt, ascending: true)
            ],
            predicate: predicate
        )
    }


    var body: some View {
        List {
            ForEach(filteredTodos, id: \.objectID) { todo in
                TodoListEntryView(
                    todoViewModel: todoViewModel,
                    todo: todo,
                    showAsSelectedForToday: todo.selectedForToday,
                    isInTodayView: false,
                    showSymbols: settingsViewModel.settings.showSymbols,
                    showDueDate: true,
                    showResistance: settingsViewModel.settings.showResistanceInAllTodosView
                )
                .id(todo.updatedAt)
                .onDrag {
                    NSItemProvider(object: String(todo.objectID.uriRepresentation().absoluteString) as NSString)
                }
                .strikethrough(todo.isDone, color: Color.theme.primary)
                .bold(todo.selectedForToday)
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
        .sheet(isPresented: $showingAddTodo) {
            TodoFormView(todoViewModel: todoViewModel, addDays: settingsViewModel.settings.daysAddedForDefaultDueDate, existingTodo: nil, category: category)
        }
        .sheet(item: $sharedTodos) { wrapper in
            let todos : [Todo] = wrapper.todos
            let dateString = StyleUtils.dateTimeFormatter.string(from: Date())
            let filename = "\(Localization.filename.exportTodo)_\(dateString)"
            let url : URL = ImportExportUtils.exportListOfTodosToJSONFile(todos: todos, fileName: filename)
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
    }

    func move(from source: IndexSet, to destination: Int) {
        todoViewModel.moveTodo(from: source, to: destination)
    }
}
