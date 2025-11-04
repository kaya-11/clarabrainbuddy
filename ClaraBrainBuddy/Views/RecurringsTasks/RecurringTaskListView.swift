//
//  Views/RecurringTasks/RecurringTodoView.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 19.03.25.
//

import SwiftUI
import CoreData

struct RecurringTaskListView: View {
    @ObservedObject var taskViewModel: TaskViewModel = .shared
    @ObservedObject var todoViewModel: TodoViewModel = TodoViewModel.shared
    @ObservedObject var settingsViewModel: SettingsViewModel = .shared

    @State private var showingAddTask = false
    
    @State private var editingTask: RecurringTask?
    
    @State private var searchText = ""
    
    @Environment(\.managedObjectContext) private var context
        
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \RecurringTask.sortOrder, ascending: true)]
    ) private var tasks: FetchedResults<RecurringTask>
    
    var filteredRecurringTasks: [RecurringTask] {
        if searchText.isEmpty {
            return Array(tasks)
        } else {
            return tasks.filter { task in
                let titleMatches = task.title.localizedCaseInsensitiveContains(searchText)
                let detailsMatches = (task.details ?? "").localizedCaseInsensitiveContains(searchText)
                return titleMatches || detailsMatches
            }
        }
    }
    
    var body: some View {
      
        NavigationView {
            VStack {
                List {
                    ForEach(filteredRecurringTasks, id: \.objectID) { (task: RecurringTask) in
                        Text(task.title)
                            .onTapGesture(count: 2) {
                                editingTask = task
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    withAnimation {
                                        taskViewModel.deleteRecurringTask(task)
                                    }
                                } label: {
                                    Label(Localization.labels.delete, systemImage: "trash")
                                }
                                .tint(.red)
                                .accessibilityIdentifier("RecurringTaskListDeleteTask")
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    editingTask = task
                                } label: {
                                    Label(Localization.labels.edit, systemImage: "pencil")
                                }
                                .tint(.green)
                                .accessibilityIdentifier("RecurringTaskListViewEditTask")
                            }
                            .foregroundColor(Color.theme.listText)
                            .listRowBackground(Color.theme.listBackground)
                            .font(Font.app.listItem)
                    }
                    .onMove(perform: move)
                }
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                .sheet(isPresented: $showingAddTask) {
                    RecurringTaskFormView(taskViewModel: taskViewModel, defaultEstimatedTime : Int64(settingsViewModel.settings.defaultEstimatedTimeForRecurringTasks), existingTask: nil)
                }
                .sheet(item: $editingTask) { (task: RecurringTask) in
                        RecurringTaskFormView(
                            taskViewModel: taskViewModel,
                            defaultEstimatedTime: nil,
                            existingTask: task
                        )
                }
                
                Spacer(minLength: 1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .backgroundStyle()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    ClaraMenuView(settingsViewModel: settingsViewModel, todoViewModel: todoViewModel)
                }
                ToolbarItem(placement: .principal) {
                    Text(Localization.labels.titleRecurringTasks)
                        .foregroundColor(Color.theme.primary)
                        .font(Font.app.title)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddTask = true
                    }) {
                        Image(systemName: "plus.circle")
                    }
                    .accessibilityIdentifier("AddRecurringTaskButton")
                }
            }
            .toolbarBackground(Color.theme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        taskViewModel.moveRecurringTask(from: source, to: destination)
    }
    
}


