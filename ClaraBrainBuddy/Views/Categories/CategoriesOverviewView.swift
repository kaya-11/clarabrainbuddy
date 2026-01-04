//
//  Views/Categories/CategoriesOverviewView.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 04.01.26.
//
import SwiftUI
import UniformTypeIdentifiers


struct CategoriesOverviewView: View {
    
    @ObservedObject var categviewModel: CategoryViewModel = CategoryViewModel.shared
    
    @ObservedObject var todoViewModel : TodoViewModel = .shared
    @ObservedObject var settingsViewModel: SettingsViewModel = .shared

    
    @Environment(\.managedObjectContext) private var context
    
    @State private var showingAddTodo = false
    @State private var selectedTodo: Todo? = nil
    @State private var showErrorMessage = false
    
    @State private var sharedTodoDetails: SharedTodoDetailsWrapper? = nil
    @State private var sharedTodos: SharedTodosWrapper? = nil
    
    @State private var selectedCategory: Category? = CategoryViewModel.shared.allCategoriess.first { category in
        category.isDefault
    }

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Category.sortOrder, ascending: true),
            NSSortDescriptor(keyPath: \Category.updatedAt, ascending: true)
        ]
    ) private var categories: FetchedResults<Category>
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Todo.sortOrder, ascending: true),
            NSSortDescriptor(keyPath: \Todo.updatedAt, ascending: true)
        ]
    ) private var todos: FetchedResults<Todo>
    
    var filteredTodos: [Todo] {
        return todos.filter { todo in
            todo.category == selectedCategory
        }
    }
    

    var body: some View {
        NavigationView {
            VStack {
            
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ],
                    spacing: 16
                ) {
                    ForEach(categories, id: \.self) { category in
                        CategoryBubbleView(category: category)
                            .id(category.updatedAt)
                            .onTapGesture {
                                selectedCategory = category
                            }
                            .onDrop(of: [UTType.text], isTargeted: nil) { providers in
                                                            handleDrop(providers: providers, category: category)
                                                        }
                    }
                }
                .padding(16)
                
                if let selectedCategory = selectedCategory {
                    List {
                        ForEach(filteredTodos, id: \.objectID) { (todo: Todo) in
                            TodoListEntryView(
                                todoViewModel: todoViewModel,
                                todo: todo,
                                showAsSelectedForToday: todo.selectedForToday,
                                isInTodayView: false,
                                showSymbols: settingsViewModel.settings.showSymbols,
                                showDueDate: true,
                                showResistance: settingsViewModel.settings.showResistanceInAllTodosView
                            )
                            .onDrag {
                                NSItemProvider(object: String(todo.objectID.uriRepresentation().absoluteString) as NSString)
                            }
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
                    .sheet(isPresented: $showingAddTodo) {
                        TodoFormView(todoViewModel: todoViewModel, addDays: settingsViewModel.settings.daysAddedForDefaultDueDate, existingTodo: nil, category: selectedCategory)
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
                    
                } else {
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .backgroundStyle()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    ClaraMenuView(settingsViewModel: settingsViewModel, todoViewModel: todoViewModel)
                }
                ToolbarItem(placement: .principal) {
                    Text("Übersicht Kategorien")
                        .foregroundColor(Color.theme.primary)
                        .font(Font.app.title)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddTodo = true
                    }) {
                        Image(systemName: "plus.circle")
                    }.accessibilityIdentifier("AddCategoryButton")
                    
                }
            }
            .accessibilityIdentifier("CategoriesOverviewContainer")
            .toolbarBackground(Color.theme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func handleDrop(providers: [NSItemProvider], category: Category?) -> Bool {
        guard let category = category else { return false }
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.text.identifier) { (item, error) in
                DispatchQueue.main.async {
                    if let data = item as? Data, let uriString = String(data: data, encoding: .utf8) {
                        findAndChangeCategoryForTodo(withURI: uriString, to: category)
                    }
                }
            }
        }
        return true
    }
    
    private func findAndChangeCategoryForTodo(withURI uriString: String, to targetCategory: Category) {
        for todo in todoViewModel.allTodos {
            if todo.objectID.uriRepresentation().absoluteString == uriString {
                todoViewModel.changeCategory(todo: todo, category: targetCategory)
                break
            }
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        todoViewModel.moveTodo(from: source, to: destination)
    }
}
