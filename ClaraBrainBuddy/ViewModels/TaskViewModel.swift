//
//  ViewModels/TodoViewModel.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//

import Foundation
import CoreData

class TaskViewModel: ObservableObject {
   
    private let context: NSManagedObjectContext

    static let shared = TaskViewModel(context: DataManager.shared.context)
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }

    var allRecurringTasks: [RecurringTask] {
        let request: NSFetchRequest<RecurringTask> = RecurringTask.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \RecurringTask.sortOrder, ascending: true)]
        
        var allRecurringTasks = [] as [RecurringTask]
        do {
            allRecurringTasks = try context.fetch(request)
        } catch {
            print("Failed to fetch tasks: \(error)")
        }
        return allRecurringTasks
        
    }

    func addRecurringTask(title: String, details: String, estimatedTime: Int64?, recurrenceRule: RecurrenceRule) {
    
        let newTask = RecurringTask(context: context)
        newTask.title = title
        newTask.details = details
        newTask.estimatedTime = estimatedTime
        newTask.recurrenceRuleAsString = recurrenceRule.encoded()
        newTask.createdAt = Date()
        newTask.sortOrder = 0
        
        var reorderedTasks = allRecurringTasks
        reorderedTasks.insert(newTask, at: 0)
        
        for (index, task) in reorderedTasks.enumerated() {
            task.sortOrder = Int64(index)
        }

        saveContext()
    }
    
    func updateRecurringTask(_ updatedTask: RecurringTask) {
        updatedTask.updatedAt = Date()
        saveContext()
    }

    func deleteRecurringTask(_ task: RecurringTask) {
        context.delete(task)
        saveContext()
    }

    func moveRecurringTask(from source: IndexSet, to destination: Int) {
        var reorderedTasks = allRecurringTasks
        reorderedTasks.move(fromOffsets: source, toOffset: destination)
        
        for (index, task) in reorderedTasks.enumerated() {
            task.sortOrder = Int64(index)
        }
        
        saveContext()
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
