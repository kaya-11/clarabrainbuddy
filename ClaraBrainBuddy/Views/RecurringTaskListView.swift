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
    
    @State private var selectedTask: RecurringTask? = nil
    
    var body: some View {
      
        NavigationView {
            VStack {
                List {
                    ForEach(taskViewModel.allRecurringTasks, id: \.self) { task in
                        Text(task.title)
                            .onTapGesture(count: 2) {
                                selectedTask = task
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    taskViewModel.deleteRecurringTask(task)
                                } label: {
                                    Label(Localization.labels.delete, systemImage: "trash")
                                }.tint(.red)
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    selectedTask = task
                                } label: {
                                    Label(Localization.labels.edit, systemImage: "pencil")
                                }.tint(.green)
                            }
                            .foregroundColor(Color.theme.listText)
                            .listRowBackground(Color.theme.listBackground)
                            .font(Font.app.listItem)
                    }
                    .onMove(perform: move)
                }
                .sheet(isPresented: $showingAddTask) {
                    RecurringTaskFormView(taskViewModel: taskViewModel, existingTask: nil)
                }
                .sheet(item: $selectedTask) { task in
                    RecurringTaskFormView(taskViewModel: taskViewModel, existingTask: task)
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
                }
            }
            .toolbarBackground(Color.theme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        taskViewModel.reorderRecurringTasks(from: source, to: destination)
    }
    
}


