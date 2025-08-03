//
//  ViewModels/TodoViewModel.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//

import Foundation

class TaskViewModel: ObservableObject {
    private let taskManager : RecurringTaskManager
    @Published var allRecurringTasks: [RecurringTask] = []

    init(taskManager: RecurringTaskManager = RecurringTaskManager()) {
        self.taskManager = taskManager
        self.allRecurringTasks = taskManager.loadTasks()
    }

    func addRecurringTask(title: String, details: String, estimatedTime: Int?, recurrenceRule: RecurrenceRule) {
    
        let newTask = RecurringTask(id: UUID(), title: title, details: details, estimatedTime: estimatedTime, recurrenceRule: recurrenceRule)

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
    
    func moveRecurringTask(from source: IndexSet, to destination: Int) {
        allRecurringTasks.move(fromOffsets: source, toOffset: destination)
        taskManager.saveTasks(allRecurringTasks)
    }
}
