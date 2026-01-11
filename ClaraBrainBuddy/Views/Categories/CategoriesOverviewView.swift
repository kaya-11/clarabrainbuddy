//
//  Views/Categories/CategoriesOverviewView.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 04.01.26.
//
import SwiftUI
import UniformTypeIdentifiers


struct CategoriesOverviewView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @ObservedObject var categegoriesViewModel: CategoryViewModel = CategoryViewModel.shared
    
    @ObservedObject var todoViewModel : TodoViewModel = .shared
    @ObservedObject var settingsViewModel: SettingsViewModel = .shared

    @State private var showingAddTodo = false
    @State private var selectedTodo: Todo? = nil
    @State private var showErrorMessage = false
    
    @State private var sharedTodoDetails: SharedTodoDetailsWrapper? = nil
    @State private var sharedTodos: SharedTodosWrapper? = nil
    
    @State private var selectedCategory: Category? = CategoryViewModel.shared.getDefaultCategory()

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Category.sortOrder, ascending: true),
            NSSortDescriptor(keyPath: \Category.updatedAt, ascending: true)
        ]
    ) private var categories: FetchedResults<Category>
    
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
                .accessibilityIdentifier("CategoriesOverviewContainer")
                .padding(16)
                
                let predicate = selectedCategory != nil ?
                    NSPredicate(format: "category == %@", selectedCategory!) :
                    NSPredicate(format: "category == nil")
                TodoListCoreView(
                    predicate: predicate,
                    category: selectedCategory,
                    todoViewModel: todoViewModel,
                    settingsViewModel: settingsViewModel,
                    selectedTodo: $selectedTodo,
                    showErrorMessage: $showErrorMessage,
                    sharedTodoDetails: $sharedTodoDetails,
                    sharedTodos: $sharedTodos,
                    showingAddTodo: $showingAddTodo
                )
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
                    }.accessibilityIdentifier("AddTodoButtonInCategoryView")
                    
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
}
