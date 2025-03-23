//
//  ViewModels/TodoViewModel.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//

import Foundation

class TaskViewModel: ObservableObject {
    private let taskManager = RecurringTaskManager()
    @Published var allRecurringTasks: [RecurringTask] = []


    init() {
        allRecurringTasks = taskManager.loadTasks()
    }

    func addRecurringTask(title: String, details: String, recurrenceRule: RecurrenceRule) {
    
        let newTask = RecurringTask(id: UUID(), title: title, details: details, recurrenceRule: recurrenceRule)

        allRecurringTasks.insert(newTask, at: 0)
        taskManager.saveTasks(allRecurringTasks)
    }
    
    func updateRecurringTask(_ updatedTask: RecurringTask) {
        if let index = allRecurringTasks.firstIndex(where: { $0.id == updatedTask.id }) {
            allRecurringTasks[index] = updatedTask
            taskManager.saveTasks(allRecurringTasks)
        }
    }
    
    func deleteRecurringTask(_ task: RecurringTask) {
        if let index = allRecurringTasks.firstIndex(where: { $0.id == task.id }) {
            allRecurringTasks.remove(at: index)
            taskManager.saveTasks(allRecurringTasks)
        }

    }
    
    func reorderRecurringTasks(from source: IndexSet, to destination: Int) {
        allRecurringTasks.move(fromOffsets: source, toOffset: destination)
        taskManager.saveTasks(allRecurringTasks)
    }
    
    func updateRecurringTasks() {
        taskManager.saveTasks(allRecurringTasks)
    }

}
