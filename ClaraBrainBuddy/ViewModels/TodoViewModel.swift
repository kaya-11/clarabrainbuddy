//
//  ViewModels/TodoViewModel.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//

import Foundation
import EventKit
import CoreData

class TodoViewModel: ObservableObject {
    
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    var allTodos: [Todo] {
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Todo.sortOrder, ascending: true)]
        
        var allTodos: [Todo] = []
        do {
            allTodos = try context.fetch(request)
        } catch {
            print("❌ Failed to fetch todos: \(error)")
        }
        return allTodos
    }
    
    var todayTodos: [TodayTodo] {
        let request: NSFetchRequest<TodayTodo> = TodayTodo.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TodayTodo.sortOrder, ascending: true)]
        
        var todayTodos: [TodayTodo] = []
        do {
            todayTodos = try context.fetch(request)
        } catch {
            print("❌ Failed to fetch todayTodos: \(error)")
        }
        return todayTodos
    }
    
    func addTodo(title: String, details: String, dueDate: Date, estimatedTime: Int64?) {
        
        let newTodo = Todo(context: context)
        newTodo.id = UUID()
        newTodo.title = title
        newTodo.details = details
        newTodo.dueDate = dueDate
        newTodo.estimatedTime = estimatedTime
        newTodo.isDone = false
        newTodo.createdAt = Date()
        newTodo.sortOrder = 0
        
        var reorderedTodos = allTodos
        reorderedTodos.append(newTodo)
        
        for (index, todo) in reorderedTodos.enumerated() {
            todo.sortOrder = Int64(index)
        }
        
        saveContext()
    }
        
    func addTodos(_ todos: [Todo]) {
        var reorderedTodos = allTodos
        var todosToMove = [Todo]()

        for incoming in todos {
            if let existingIndex = reorderedTodos.firstIndex(where: { $0.objectID == incoming.objectID }) {
                todosToMove.append(reorderedTodos.remove(at: existingIndex))
            } else {
                context.insert(incoming)
                todosToMove.append(incoming)
            }
        }

        reorderedTodos.insert(contentsOf: todosToMove, at: 0)

        for (index, todo) in reorderedTodos.enumerated() {
            todo.sortOrder = Int64(index)
        }

        saveContext()
    }
    
    func addRecurringTaskAsTodoForToday(_ recurringTask: RecurringTask) {
        addNewTodoForToday(title: recurringTask.title, details: recurringTask.details ?? "", estimatedTime: recurringTask.estimatedTime, recurringTask: recurringTask)
    }
    
    func selectForToday(_ todo: Todo, _ recurringTask: RecurringTask? = nil) {
        let allTodos: [Todo] = allTodos
        var allTodosForToday: [TodayTodo] = todayTodos
        
        guard allTodos.contains(where: { $0.objectID == todo.objectID }) else { return }
        
        guard !allTodosForToday.contains(where: { $0.todo.objectID == todo.objectID }) else { return }
        
        let newTodayTodo = TodayTodo(context: context)
        newTodayTodo.id = UUID()
        newTodayTodo.selectedForTodayAt = Date()
        newTodayTodo.todo = todo
        newTodayTodo.recurringTask = recurringTask
        newTodayTodo.sortOrder = 0
        
        todo.selectedForToday = true
        
        allTodosForToday.insert(newTodayTodo, at: 0)
        
        for (index, todayTodo) in allTodosForToday.enumerated() {
            todayTodo.sortOrder = Int64(index)
        }
        
        saveContext()
    }
    
    func deselectForToday(_ todo: Todo) {
        let todayTodos: [TodayTodo] = todayTodos
        
        if let todayTodo = todayTodos.first(where: { $0.todo == todo }) {
            context.delete(todayTodo)
        }
        todo.selectedForToday = false
        todo.resistance = increaseResistance(resistance: todo.resistance)
        
        saveContext()
    }
    
    func eventAlreadyExistsAsTodo(_ event: EKEvent) -> Bool {
        let calendar = Calendar.current

        // Extract day, month, and year from event.startDate
        let startDateComponents = calendar.dateComponents([.day, .month, .year], from: event.startDate)
        guard let startDateWithoutTime = calendar.date(from: startDateComponents) else {
            return false
        }

        // Compare the title and the date without time
        let allTodos: [Todo] = allTodos
        return allTodos.contains { todo in
            let todoDueDateComponents = calendar.dateComponents([.day, .month, .year], from: todo.dueDate)
            guard let todoDueDateWithoutTime = calendar.date(from: todoDueDateComponents) else {
                return false
            }

            return todo.title == event.title && todoDueDateWithoutTime == startDateWithoutTime
        }
    }
    
    func addNewTodoForToday(
        title: String,
        details: String,
        estimatedTime: Int64?,
        recurringTask: RecurringTask? = nil
    ) {
       
        let newTodo = Todo(context: self.context)
        newTodo.id = UUID()
        newTodo.title = title
        newTodo.details = details
        newTodo.dueDate = Date()
        newTodo.estimatedTime = estimatedTime
        newTodo.isDone = false              // <- WICHTIG, falls non-optional
        newTodo.createdAt = Date()          // <- WICHTIG, falls non-optional
        newTodo.selectedForToday = true     // optional, aber konsistent
        newTodo.sortOrder = 0
        
        let newTodayTodo = TodayTodo(context: self.context)
        newTodayTodo.id = UUID()
        newTodayTodo.selectedForTodayAt = Date()
        newTodayTodo.todo = newTodo
        newTodayTodo.sortOrder = 0
        newTodayTodo.recurringTask = recurringTask
        
        var reorderedTodos = allTodos
        reorderedTodos.insert(newTodo, at: 0)
        
        for (index, todo) in reorderedTodos.enumerated() {
            todo.sortOrder = Int64(index)
        }
        
        var reorderedTodaysTodos = todayTodos
        reorderedTodaysTodos.insert(newTodayTodo, at: 0)
        
        for (index, todayTodo) in reorderedTodaysTodos.enumerated() {
            todayTodo.sortOrder = Int64(index)
        }
                        
        saveContext()
        
    }
    
    func getTotalEstimatedTime(defaultEstimatedTime: Int64 = 15) -> Int64 {
        return todayTodos.compactMap { todayTodo in
            if let todo = allTodos.first(where: { $0 == todayTodo.todo }) {
                let estimatedTime = todo.estimatedTime == nil ? defaultEstimatedTime : todo.estimatedTime
                return todo.isDone ? nil : estimatedTime
            }
            return nil
        }.reduce(0, +)
    }
    
    func deleteTodo(_ todo: Todo) {
        if let todayTodo = todayTodos.first(where: { $0.todo.objectID == todo.objectID }) {
            context.delete(todayTodo)
        }
        context.delete(todo)
        saveContext()
        DeviceFeedback.vibrate()
    }
    
    func isRecurringTaskInTodayTodos(_ recurringTask: RecurringTask) -> Bool {
        return todayTodos.contains(where: { $0.recurringTask == recurringTask })
    }
    
    func moveTodo(from source: IndexSet, to destination: Int) {
        var reordered = allTodos
        reordered.move(fromOffsets: source, toOffset: destination)
        for (index, todo) in reordered.enumerated() {
            todo.sortOrder = Int64(index)
        }
        saveContext()
    }
    
    func moveTodayTodos(from source: IndexSet, to destination: Int) {
        var reordered = todayTodos
        reordered.move(fromOffsets: source, toOffset: destination)
        for (index, today) in reordered.enumerated() {
            today.sortOrder = Int64(index)
        }
        saveContext()
    }
    
    func setToDone(_ todayTodo: TodayTodo) {
        let updatedAt = Date()
        
        let todo = todayTodo.todo
        
        todo.isDone = true
        todo.updatedAt = updatedAt
        
        todayTodo.todo = todo
        
        saveContext()
    }
    
    func updateTodo(_ updatedTodo: Todo) {
        saveContext()
    }
    
    func cloneTodo(todo: Todo) {
        var reorderedTodos = allTodos
        
        let clone = Todo(context: context)
        clone.id = UUID()
        clone.title = "Clone - \(todo.title)"
        clone.details = todo.details
        clone.dueDate = todo.dueDate
        clone.estimatedTime = todo.estimatedTime
        clone.isDone = false
        clone.createdAt = Date()
        clone.sortOrder = 0
        
        reorderedTodos.insert(clone, at: 0)
        
        for (index, todo) in reorderedTodos.enumerated() {
            todo.sortOrder = Int64(index)
        }
        
        saveContext()
    }
    
    func randomTodo() -> Todo? {
        let availableTodos = allTodos.filter { !$0.selectedForToday }
        return availableTodos.randomElement()
    }

    func moveTodoOneDown(_ todo: Todo) {
        var reorderedTodos = allTodos
        guard let currentIndex = reorderedTodos.firstIndex(of: todo) else { return }

        // Increase resistance
        todo.resistance = increaseResistance(resistance: todo.resistance)

        let newIndex = currentIndex + 1
        if newIndex < reorderedTodos.count {
            // Swap sortOrder values of the two todos
            let todoBelow = allTodos[newIndex]
            let tempSortOrder = todo.sortOrder
            todo.sortOrder = todoBelow.sortOrder
            todoBelow.sortOrder = tempSortOrder

            // Update the array to match the new order
            reorderedTodos.swapAt(currentIndex, newIndex)

            saveContext()
        }
    }

    func moveToTheTop(_ todo: Todo) {
        guard allTodos.contains(where: { $0.objectID == todo.objectID }) else { return }

        // Stelle sicher, dass die Todos nach aktueller Sortierung sortiert sind
        let sorted = allTodos.sorted(by: { $0.sortOrder < $1.sortOrder })

        // Baue die neue Reihenfolge: todo zuerst, dann alle anderen
        let reordered = [todo] + sorted.filter { $0.objectID != todo.objectID }

        // Vergib neue sortOrder ohne Lücken
        for (index, t) in reordered.enumerated() {
            t.sortOrder = Int64(index)   // oder Int32 je nach Typ
        }
        
        selectForToday(todo)

        saveContext()
    }
    
    func reorderTodayTodos() {
        var reorderedTodayTodos = todayTodos
        reorderedTodayTodos.sort { first, second in
            let todo1 = first.todo
            let todo2 = second.todo
            
            // The completed todos to the end.
            if todo1.isDone != todo2.isDone {
                return !todo1.isDone
            }
            
            let est1 = todo1.estimatedTime ?? 0
            let est2 = todo2.estimatedTime ?? 0
            
            // Todos with no estimated time to the top
            if est1 == 0 && est2 != 0 {
                return true
            }
            
            if ( est1 != est2 ) {
                return est1 < est2
            }
            return (todo1.dueDate) < (todo2.dueDate)
        }
        for (index, today) in reorderedTodayTodos.enumerated() {
            today.sortOrder = Int64(index)
        }
        saveContext()
    }
    
    func getTotalTodaysTodosCount() -> Int {
        return todayTodos.count
    }
    
    private func increaseResistance(resistance: Int64) -> Int64 {
        var r = resistance
        if r <= 10 { r += 1 }
        return r
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("❌ Save failed: \(error)")
        }
    }

}
