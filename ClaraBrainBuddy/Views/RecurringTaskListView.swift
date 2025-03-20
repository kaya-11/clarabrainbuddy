//
//  Views/RecurringTodoView.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 19.03.25.
//

import SwiftUI

struct RecurringTaskListView: View {
    @ObservedObject var taskViewModel: TaskViewModel
    
    @State private var showingAddTask = false
    
    @State private var showingEditTask = false
    @State private var selectedTask: RecurringTask? = nil
    
    var body: some View {
      
        NavigationView {
            VStack {
                List {
                    ForEach(taskViewModel.allRecurringTasks, id: \.self) { task in
                        Text(task.title)
                            .onTapGesture(count: 2) {
                                selectedTask = task
                                showingEditTask = true
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    taskViewModel.deleteRecurringTask(task)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }.tint(.red)
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    selectedTask = task
                                    showingEditTask = true
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }.tint(.green)
                            }
                            .foregroundColor(Colors.listText)
                            .listRowBackground(Colors.listBackground)
                    }
                    .onMove(perform: move)
                }
                .scrollContentBackground(.hidden) // Hide the default background
                .backgroundStyle()
                .navigationTitle("All Recurring Tasks")
                .navigationBarItems(
                    leading: EditButton(),
                    trailing: Button(action: {
                        showingAddTask = true
                    }) {
                        Image(systemName: "plus")
                    })
                .sheet(isPresented: $showingAddTask) {
                    RecurringTaskFormView(taskViewModel: taskViewModel, existingTask: nil)
                }
                .sheet(isPresented: $showingEditTask) {
                    RecurringTaskFormView(taskViewModel: taskViewModel, existingTask: selectedTask)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .backgroundStyle()
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        taskViewModel.reorderRecurringTasks(from: source, to: destination)
    }
    
}


