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
    
    @Published var allTodos: [Todo] = []
    @Published var todayTodos: [TodayTodo] = []

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchTodos()
        fetchTodayTodos()
    }
    
    func fetchTodos() {
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Todo.sortOrder, ascending: true)]
        do {
            allTodos = try context.fetch(request)
        } catch {
            print("❌ Failed to fetch todos: \(error)")
        }
    }
    
    func fetchTodayTodos() {
        let request: NSFetchRequest<TodayTodo> = TodayTodo.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TodayTodo.sortOrder, ascending: true)]
        do {
            todayTodos = try context.fetch(request)
        } catch {
            print("❌ Failed to fetch todayTodos: \(error)")
        }
    }
    
    func addTodo(title: String, details: String, dueDate: Date, estimatedTime: Int64?) {
        // Shift existing sort orders
        for todo in allTodos {
            todo.sortOrder += 1
        }
        
        let newTodo = Todo(context: context)
        newTodo.id = UUID()
        newTodo.title = title
        newTodo.details = details
        newTodo.dueDate = dueDate
        newTodo.estimatedTime = estimatedTime
        newTodo.isDone = false
        newTodo.createdAt = Date()
        newTodo.sortOrder = 0
        
        saveContext()
        fetchTodos()
    }
    
    func addTodos(_ todos: [Todo]) {
        
        for todo in allTodos {
            todo.sortOrder += Int64(todos.count)
        }
        
        var sortOrder : Int64 = 0
        for incoming in todos {
            incoming.sortOrder = sortOrder
            context.insert(incoming)
            sortOrder += 1
        }
        
        saveContext()
        fetchTodos()
    }
    
    func addRecurringTaskAsTodoForToday(_ recurringTask: RecurringTask) {
        addNewTodoForToday(title: recurringTask.title, details: recurringTask.details ?? "", estimatedTime: recurringTask.estimatedTime, recurringTask: recurringTask)
    }
    
    func selectForToday(_ todo: Todo, _ recurringTask: RecurringTask? = nil) {
        guard allTodos.contains(where: { $0.id == todo.id }) else { return }
        
        guard !todayTodos.contains(where: { $0.todo.id == todo.id }) else { return }
        
        // Shift today sort orders
        for today in todayTodos {
            today.sortOrder += 1
        }
        
        let todayTodo = TodayTodo(context: context)
        todayTodo.id = UUID()
        todayTodo.selectedForTodayAt = Date()
        todayTodo.todo = todo
        todayTodo.recurringTask = recurringTask
        todayTodo.sortOrder = 0
        
        todo.selectedForToday = true
        
        saveContext()
        fetchTodos()
        fetchTodayTodos()
    }
    
    func deselectForToday(_ todo: Todo) {
        if let todayTodo = todayTodos.first(where: { $0.todo == todo }) {
            context.delete(todayTodo)
        }
        todo.selectedForToday = false
        todo.resistance = increaseResistance(resistance: todo.resistance)
        
        saveContext()
        fetchTodos()
        fetchTodayTodos()
    }
    
    func eventAlreadyExistsAsTodo(_ event: EKEvent) -> Bool {
        let calendar = Calendar.current

        // Extract day, month, and year from event.startDate
        let startDateComponents = calendar.dateComponents([.day, .month, .year], from: event.startDate)
        guard let startDateWithoutTime = calendar.date(from: startDateComponents) else {
            return false
        }

        // Compare the title and the date without time
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
        do {
            self.allTodos.forEach { $0.sortOrder += 1 }
            self.todayTodos.forEach { $0.sortOrder += 1 }
            
            let todo = Todo(context: self.context)
            todo.id = UUID()
            todo.title = title
            todo.details = details
            todo.dueDate = Date()
            todo.estimatedTime = estimatedTime
            todo.isDone = false              // <- WICHTIG, falls non-optional
            todo.createdAt = Date()          // <- WICHTIG, falls non-optional
            todo.selectedForToday = true     // optional, aber konsistent
            todo.sortOrder = 0
            
            let today = TodayTodo(context: self.context)
            today.id = UUID()
            today.selectedForTodayAt = Date()
            today.todo = todo
            today.sortOrder = 0
            today.recurringTask = recurringTask
                        
            try self.context.save()
            self.fetchTodos()
            self.fetchTodayTodos()
        } catch {
            let nsErr = error as NSError
            print("❌ Save failed: \(nsErr), userInfo: \(nsErr.userInfo)")
            self.context.rollback()
        }
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
        if let todayTodo = todayTodos.first(where: { $0.todo.id == todo.id }) {
            context.delete(todayTodo)
        }
        context.delete(todo)
        saveContext()
        fetchTodos()
        fetchTodayTodos()
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
        fetchTodos()
    }
    
    func moveTodayTodos(from source: IndexSet, to destination: Int) {
        var reordered = todayTodos
        reordered.move(fromOffsets: source, toOffset: destination)
        for (index, today) in reordered.enumerated() {
            today.sortOrder = Int64(index)
        }
        saveContext()
        fetchTodayTodos()
    }
    
    func setToDone(_ todo: Todo) {
        todo.isDone = true
        saveContext()
        fetchTodos()
    }
    
    func updateTodo(_ updatedTodo: Todo) {
        saveContext()
        fetchTodos()
    }
    
    func cloneTodo(todo: Todo) {
        for t in allTodos {
            t.sortOrder += 1
        }
        
        let clone = Todo(context: context)
        clone.id = UUID()
        clone.title = "Clone - \(todo.title)"
        clone.details = todo.details
        clone.dueDate = todo.dueDate
        clone.estimatedTime = todo.estimatedTime
        clone.isDone = false
        clone.createdAt = Date()
        clone.sortOrder = 0
        
        saveContext()
        fetchTodos()
    }
    
    func randomTodo() -> Todo? {
        let availableTodos = allTodos.filter { !$0.selectedForToday }
        return availableTodos.randomElement()
    }

    func moveTodoOneDown(_ todo: Todo) {
        guard let currentIndex = allTodos.firstIndex(of: todo) else { return }

        // Increase resistance
        todo.resistance = increaseResistance(resistance: todo.resistance)

        let newIndex = currentIndex + 1
        if newIndex < allTodos.count {
            // Swap sortOrder values of the two todos
            let todoBelow = allTodos[newIndex]
            let tempSortOrder = todo.sortOrder
            todo.sortOrder = todoBelow.sortOrder
            todoBelow.sortOrder = tempSortOrder

            // Update the array to match the new order
            allTodos.swapAt(currentIndex, newIndex)

            saveContext()
        }
    }

    func moveToTheTop(_ todo: Todo) {
        guard allTodos.contains(where: { $0.id == todo.id }) else { return }

        // Stelle sicher, dass die Todos nach aktueller Sortierung sortiert sind
        let sorted = allTodos.sorted(by: { $0.sortOrder < $1.sortOrder })

        // Baue die neue Reihenfolge: todo zuerst, dann alle anderen
        let reordered = [todo] + sorted.filter { $0.id != todo.id }

        // Vergib neue sortOrder ohne Lücken
        for (index, t) in reordered.enumerated() {
            t.sortOrder = Int64(index)   // oder Int32 je nach Typ
        }
        
        selectForToday(todo)

        saveContext()
        fetchTodos()
    }
    
    func reorderTodayTodos() {
        todayTodos.sort { first, second in
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
        for (index, today) in todayTodos.enumerated() {
            today.sortOrder = Int64(index)
        }
        saveContext()
        fetchTodayTodos()
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
