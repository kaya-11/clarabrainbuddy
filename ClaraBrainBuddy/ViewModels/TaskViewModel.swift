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

    @Published var allRecurringTasks: [RecurringTask] = []

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchTasks()
    }

    func fetchTasks() {
        let request: NSFetchRequest<RecurringTask> = RecurringTask.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \RecurringTask.sortOrder, ascending: true)]
        
        do {
            allRecurringTasks = try context.fetch(request)
        } catch {
            print("Failed to fetch tasks: \(error)")
            allRecurringTasks = []
        }
    }

    func addRecurringTask(title: String, details: String, estimatedTime: Int64?, recurrenceRule: RecurrenceRule) {
    
        let newTask = RecurringTask(context: context)
        newTask.id = UUID()
        newTask.title = title
        newTask.details = details
        newTask.estimatedTime = estimatedTime
        newTask.recurrenceRuleAsString = recurrenceRule.encoded()
        newTask.createdAt = Date()
        newTask.updatedAt = Date()
        newTask.sortOrder = Int64(allRecurringTasks.count)

        saveContext()
        fetchTasks()
    }
    
    func updateRecurringTask(_ updatedTask: RecurringTask) {
        updatedTask.updatedAt = Date()
        saveContext()
        fetchTasks()
    }

    func deleteRecurringTask(_ task: RecurringTask) {
        context.delete(task)
        saveContext()
        fetchTasks()
    }

    func moveRecurringTask(from source: IndexSet, to destination: Int) {
        var reorderedTasks = allRecurringTasks
        reorderedTasks.move(fromOffsets: source, toOffset: destination)
        
        for (index, task) in reorderedTasks.enumerated() {
            task.sortOrder = Int64(index)
        }
        
        saveContext()
        fetchTasks()
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
