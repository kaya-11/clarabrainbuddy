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
    
    static let TITLE_MAX_LENGTH: Int = 100
    static let DETAILS_MAX_LENGTH: Int = 500
    
    static let shared = TodoViewModel(context: DataManager.shared.context)
    
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
    
    func addTodo(title: String, details: String, dueDate: Date, estimatedTime: Int64?, energyImpact: Int64 = 0,
                 category: Category? = nil) {
        
        let newTodo = Todo(context: context)
        newTodo.title = title
        newTodo.details = details
        newTodo.dueDate = dueDate
        newTodo.estimatedTime = estimatedTime
        newTodo.energyImpact = energyImpact
        newTodo.isDone = false
        newTodo.createdAt = Date()
        newTodo.category = category
        newTodo.sortOrder = 0
        
        var reorderedTodos = allTodos
        reorderedTodos.insert(contentsOf: [newTodo], at: 0)
        
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
        addNewTodoForToday(title: recurringTask.title, details: recurringTask.details ?? "", estimatedTime: recurringTask.estimatedTime, category: recurringTask.category, recurringTask: recurringTask)
    }
    
    func selectForToday(_ todo: Todo, _ recurringTask: RecurringTask? = nil) {
        let allTodos: [Todo] = allTodos
        var allTodosForToday: [TodayTodo] = todayTodos
        
        guard allTodos.contains(where: { $0.objectID == todo.objectID }) else { return }
        
        guard !allTodosForToday.contains(where: { $0.todo.objectID == todo.objectID }) else { return }
        
        let newTodayTodo = TodayTodo(context: context)
        newTodayTodo.selectedForTodayAt = Date()
        newTodayTodo.todo = todo
        newTodayTodo.recurringTask = recurringTask
        newTodayTodo.sortOrder = 0
        
        todo.selectedForToday = true
        todo.updatedAt = Date()
        
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
        todo.updatedAt = Date()
        if (!todo.isDone) {
            todo.resistance = ResistanceUtils.increaseResistance(resistance: todo.resistance)
        }
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
        energyImpact: Int64 = 0,
        category: Category? = nil,
        recurringTask: RecurringTask? = nil
    ) {
       
        let newTodo = Todo(context: self.context)
        newTodo.title = title
        newTodo.details = details
        newTodo.dueDate = Date()
        newTodo.estimatedTime = estimatedTime
        newTodo.energyImpact = energyImpact
        newTodo.isDone = false
        newTodo.createdAt = Date()
        newTodo.selectedForToday = true
        newTodo.category = category
        newTodo.sortOrder = 0
        
        let newTodayTodo = TodayTodo(context: self.context)
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
    
    func getTotalEstimatedTime(defaultEstimatedTime : Int = 15) -> Int64 {
        let notCompletedTodos: [Todo] = todayTodos.count > 0 ? todayTodos.filter { !$0.todo.isDone }.map { $0.todo } : []
        return calculateEstimatedTime(todos: notCompletedTodos, defaultEstimatedTime: defaultEstimatedTime)
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
    
    func moveTodo(source: Todo, destination: Todo, aftereDestination: Bool = false) {
        
        var reordered = allTodos
                
        guard let sourceIndex = allTodos.firstIndex(where: { $0.id == source.id }),
              let destIndex = allTodos.firstIndex(where: { $0.id == destination.id }) else {
            return
        }

        let sourceTodo = reordered.remove(at: sourceIndex)
        
        let insertIndex = destIndex > sourceIndex && !aftereDestination ? destIndex - 1 : destIndex
        
        reordered.insert(sourceTodo, at: insertIndex)
        
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
        
        todayTodo.updatedAt = Date()
        
        saveContext()
    }
    
    func updateTodo(_ todo: Todo, form: TodoFormData) -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        
        let ogIsDone = todo.isDone
        let newIsDone = form.isDone
        
        todo.title = form.title
        todo.details = form.details

        let ogDueDate = todo.dueDate
        let newDueDate = Calendar.current.startOfDay(for: form.dueDate)
        
        if (form.isDone != true && newDueDate > ogDueDate) {
            todo.resistance = ResistanceUtils.increaseResistance(resistance: todo.resistance)
        } else if (form.isDone != true && newDueDate < ogDueDate && newDueDate >= today) {
            todo.resistance = ResistanceUtils.decreaseResistance(resistance: todo.resistance)
        }

        todo.dueDate = form.dueDate
        todo.estimatedTime = form.estimatedTime
        todo.energyImpact = form.energyImpact ?? 0
        todo.updatedAt = Date()
        todo.isDone = form.isDone
        todo.category = form.category
        self.updateTodo(todo)
        
        return newIsDone && !ogIsDone // return true, if task is changed to done
    }
    
    
    func updateTodo(_ updatedTodo: Todo) {
        updatedTodo.updatedAt = Date()
        let fetchRequest: NSFetchRequest<TodayTodo> = TodayTodo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "todo == %@",  updatedTodo)
        do {
            let todayTodos = try updatedTodo.managedObjectContext?.fetch(fetchRequest) ?? []
            for todayTodo in todayTodos {
                todayTodo.updatedAt = Date()
            }
        } catch {
            print("Error fetching TodayTodos: \(error)")
        }
        saveContext()
    }
    
    
    func cloneTodo(todo: Todo) {
        var reorderedTodos = allTodos
        
        let clone = Todo(context: context)
        clone.title = "\(Localization.labels.clone) - \(todo.title)"
        clone.details = todo.details
        clone.dueDate = todo.dueDate
        clone.estimatedTime = todo.estimatedTime
        clone.energyImpact = todo.energyImpact
        clone.isDone = false
        clone.createdAt = Date()
        clone.category = todo.category
        clone.sortOrder = 0
        
        reorderedTodos.insert(clone, at: 0)
        
        for (index, todo) in reorderedTodos.enumerated() {
            todo.sortOrder = Int64(index)
        }
        
        saveContext()
    }
    
    func randomTodo() -> Todo? {
        let availableTodos = allTodos.filter { !$0.selectedForToday }
        guard !availableTodos.isEmpty else { return nil }
        
        let totalWeight = availableTodos.reduce(0) { $0 + weight(for: $1) }
        var randomValue = Int.random(in: 0..<totalWeight)
        
        for todo in availableTodos {
            randomValue -= weight(for: todo)
            if randomValue < 0 {
                return todo
            }
        }
        
        return nil
    }
    
    func weight(for todo: Todo) -> Int {
        let now = Date()
        let dueDate : Date = todo.dueDate
        
        if dueDate <= now.addingTimeInterval(7 * 24 * 60 * 60) { // bis 1 Woche in der Zukunft
            return 8
        } else if dueDate <= now.addingTimeInterval(21 * 24 * 60 * 60) { // 1 bis 3 Wochen
            return 4
        } else if dueDate <= now.addingTimeInterval(84 * 24 * 60 * 60) { // 4 bis 12 Wochen
            return 2
        } else {
            return 1 // alle anderen
        }
    }

    func moveTodoOneDown(_ todo: Todo) {
        var reorderedTodos = allTodos
        guard let currentIndex = reorderedTodos.firstIndex(of: todo) else { return }

        // Increase resistance
        todo.resistance = ResistanceUtils.increaseResistance(resistance: todo.resistance)
        todo.updatedAt = Date()

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
        
        todo.updatedAt = Date()
        
        selectForToday(todo)

        saveContext()
    }
    
    func reorderTodayTodos(defaultEstimatedTime: Int = 0) {
        var reorderedTodayTodos = todayTodos
        reorderedTodayTodos.sort { first, second in
            let todo1 = first.todo
            let todo2 = second.todo
            
            // The completed todos to the end.
            if todo1.isDone != todo2.isDone {
                return !todo1.isDone
            }
            
            let est1 = todo1.estimatedTime ?? Int64(defaultEstimatedTime)
            let est2 = todo2.estimatedTime ?? Int64(defaultEstimatedTime)
            
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
    
    func reorderTodos() {
        var reorderedTodos = allTodos
        reorderedTodos.sort { first, second in
            
            if first.dueDate == second.dueDate {
                return first.createdAt > second.createdAt
            }
            
            return first.dueDate < second.dueDate
        }
        for (index, todo) in reorderedTodos.enumerated() {
            todo.sortOrder = Int64(index)
        }
        saveContext()
    }
    
    func rescheduleTodo(todo: Todo) {
        let dueDate = todo.dueDate
        todo.dueDate = dueDate.addingTimeInterval(28*24*3600) // add 4 Weeks to due date
        todo.resistance = ResistanceUtils.increaseResistance(resistance: todo.resistance)
        todo.updatedAt = Date()
        saveContext()
    }
    
    func reprioritizeTodos(importantAndUrgentTasks: [Todo], urgentTasks: [Todo], importantTasks: [Todo], nothingOfBothTasks: [Todo]) {
        // 1. Remove all tasks from todayTodos that are in any of the provided lists
        let allTodayTodos = todayTodos
        for todayTodo in allTodayTodos {
            let todo = todayTodo.todo
            if nothingOfBothTasks.contains(where: { $0.objectID == todo.objectID }) ||
               importantTasks.contains(where: { $0.objectID == todo.objectID }) {
                context.delete(todayTodo)
                todo.selectedForToday = false
                todo.updatedAt = Date()
            }
        }
        
        // 2. Reorder todayTodos
        let allTodayTodosAfterRemoval = todayTodos // Fetch again after removal
        var importantAndUrgentTodayTodos = [TodayTodo]()
        var urgentTodayTodos = [TodayTodo]()
        var otherTodayTodos = [TodayTodo]()
        
        for todayTodo in allTodayTodosAfterRemoval {
            let todo = todayTodo.todo
            if importantAndUrgentTasks.contains(where: { $0.objectID == todo.objectID }) {
                importantAndUrgentTodayTodos.append(todayTodo)
            } else if urgentTasks.contains(where: { $0.objectID == todo.objectID }) {
                urgentTodayTodos.append(todayTodo)
            } else {
                otherTodayTodos.append(todayTodo)
            }
        }

        var reorderedTodayTodos = [TodayTodo]()
        reorderedTodayTodos.append(contentsOf: importantAndUrgentTodayTodos)
        reorderedTodayTodos.append(contentsOf: urgentTodayTodos)
        reorderedTodayTodos.append(contentsOf: otherTodayTodos)
        
        for (index, todayTodo) in reorderedTodayTodos.enumerated() {
            todayTodo.sortOrder = Int64(index)
        }

        // 3. Reorder allTodos
        let allTodosSet = Set(allTodos)
        let allListedTodos = Set(importantAndUrgentTasks + urgentTasks + importantTasks + nothingOfBothTasks)
        let otherTodos = Array(allTodosSet.subtracting(allListedTodos)).sorted { $0.sortOrder < $1.sortOrder }

        var reorderedTodos = [Todo]()
        reorderedTodos.append(contentsOf: importantAndUrgentTasks)
        reorderedTodos.append(contentsOf: urgentTasks)
        reorderedTodos.append(contentsOf: importantTasks)
        reorderedTodos.append(contentsOf: nothingOfBothTasks)
        reorderedTodos.append(contentsOf: otherTodos)

        for (index, todo) in reorderedTodos.enumerated() {
            todo.sortOrder = Int64(index)
        }

        // 4. Save the context
        saveContext()
    }
    
    func getTotalTodaysTodosCountNotDone() -> Int {
        return todayTodos.filter { !$0.todo.isDone }.count
    }

    func calculateCompletedTodaysTodos(defaultEstimatedTime: Int = 15) -> (count: Int, totalTime: Int64) {
        let completedTodos = todayTodos.filter { $0.todo.isDone }
        
        let totalTime = calculateEstimatedTime(todos: completedTodos.map(\.todo), defaultEstimatedTime: defaultEstimatedTime)

        return (completedTodos.count, totalTime)
    }
    
    func deleteCompletedTodos() {
        let completedTodayTodos = todayTodos.filter { $0.todo.isDone }

        for todayTodo in completedTodayTodos {
            
            let todo = todayTodo.todo
            
            context.delete(todayTodo)

            context.delete(todo)
        }

        saveContext()
    }
    
    func changeCategory(todo: Todo, category: Category) {
        todo.category = category
        todo.updatedAt = Date()
        saveContext()
    }
    
    private func calculateEstimatedTime(todos: [Todo], defaultEstimatedTime: Int) -> Int64 {
        let totalTime: Int64 = todos.reduce(0) { result, todoItem in
            let baseTime = Double(todoItem.estimatedTime ?? Int64(defaultEstimatedTime))
            let resistance = Int64(min(10,max(todoItem.resistance,0)))

            let penaltyFactor = 1.0 + (Double(resistance) * 0.2)
            let penalizedTime = baseTime * max(1.0, min(3.0, penaltyFactor))

            return result + Int64(penalizedTime)
        }
        return totalTime
    }
        
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("❌ Save failed: \(error)")
        }
    }

}
