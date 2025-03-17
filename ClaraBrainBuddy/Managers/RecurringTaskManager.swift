//
//  Managers/TodoManager.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//

import Foundation

class RecurringTaskManager {
    private let taskKey = "recurring_tasks"

    func saveTasks(_ tasks: [RecurringTask]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: taskKey)
        }
    }

    func loadTasks() -> [RecurringTask] {
        if let data = UserDefaults.standard.data(forKey: taskKey) {
            let decoder = JSONDecoder()
            if let tasks = try? decoder.decode([RecurringTask].self, from: data) {
                return tasks
            }
        }
        return []
    }
    
}
