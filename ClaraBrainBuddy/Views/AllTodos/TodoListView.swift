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
     
    var body: some View {
      
        NavigationView {
            VStack {
                TodoListCoreView(
                    predicate: searchText.isEmpty
                        ? NSPredicate(value: true)  // Gibt alle Todos zurück
                        : NSPredicate(format: "title CONTAINS[c] %@ OR details CONTAINS[c] %@ OR category.name CONTAINS[c] %@", searchText, searchText, searchText),
                    category: nil,
                    todoViewModel: todoViewModel,
                    settingsViewModel: settingsViewModel,
                    selectedTodo: $selectedTodo,
                    showErrorMessage: $showErrorMessage,
                    sharedTodoDetails: $sharedTodoDetails,
                    sharedTodos: $sharedTodos,
                    showingAddTodo: $showingAddTodo
                )
                
                Spacer(minLength: 1)
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
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
                    HStack {
                        Button(action: {
                            todoViewModel.reorderTodos()
                        }) {
                            CombinedImageView(imageMain: "calendar", imageSmall: "arrow.down")
                        }.accessibilityIdentifier("ReorderTodos")
                        Button(action: {
                            showingAddTodo = true
                        }) {
                            Image(systemName: "plus.circle")
                        }.accessibilityIdentifier("AddTodoButton")
                    }
                }
            }
            .accessibilityIdentifier("AllTodosListContainer")
            .toolbarBackground(Color.theme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
        }
    }  
}
