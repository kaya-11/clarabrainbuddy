//
//  ViewModels/TodoViewModel.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//

import Foundation
import EventKit

class TodoViewModel: ObservableObject {
    private let todoManager = TodoManager()
    @Published var allTodos: [Todo] = []
    @Published var todayTodos: [TodayTodo] = []
    
    init() {
        allTodos = todoManager.loadTodos()
        todayTodos = todoManager.loadTodayTodos()
    }
    
    func addTodo(title: String, details: String, dueDate: Date?, estimatedTime: Int?) {
        
        let newTodo = Todo(id: UUID(), title: title, details: details, dueDate: dueDate, estimatedTime: estimatedTime)
        
        allTodos.insert(newTodo, at: 0)
        todoManager.saveTodos(allTodos)
    }
    
    func addRecurringTaskAsTodoForToday(_ recurringTask: RecurringTask) {
        addNewTodoForToday(title: recurringTask.title, details: recurringTask.details ?? "", estimatedTime: recurringTask.estimatedTime, recurringTaskId: recurringTask.id)
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
            let todoDueDateComponents = calendar.dateComponents([.day, .month, .year], from: todo.dueDate ?? Date())
            guard let todoDueDateWithoutTime = calendar.date(from: todoDueDateComponents) else {
                return false
            }

            return todo.title == event.title && todoDueDateWithoutTime == startDateWithoutTime
        }
    }
    
    func addNewTodoForToday(title: String, details: String, estimatedTime: Int?, recurringTaskId: UUID? = nil) {
        let newTodo = Todo(
            id: UUID(),
            title: title,
            details: details,
            dueDate: Date(),
            estimatedTime: estimatedTime
        )
        allTodos.insert(newTodo, at: 0)
        selectForToday(newTodo, recurringTaskId)
    }
    
    func selectForToday(_ todo: Todo, _ recurringTaskId: UUID? = nil) {
        
        guard let index = allTodos.firstIndex(of: todo) else { return }
        
        allTodos[index].isSelectedForToday = true
        
        let alreadyInToday = todayTodos.contains(where: { $0.todoId == todo.id })
        if !alreadyInToday {
            let newTodayTodo = TodayTodo(id: UUID(), todoId: todo.id, recurringTaskId: recurringTaskId)
            todayTodos.append(newTodayTodo)
        }
        
        todoManager.saveTodos(allTodos)
        todoManager.saveTodayTodos(todayTodos)
        saveMostRecentTodo()
    }
    
    func deselectForToday(_ todo: Todo) {
        if let todoIndex = allTodos.firstIndex(of: todo) {
            allTodos[todoIndex].isSelectedForToday = false
            allTodos[todoIndex].resistance = increaseResistance(resistance: todo.resistance)
            todoManager.saveTodos(allTodos)
        }
        
        if let todayIndex = todayTodos.firstIndex(where: { $0.todoId == todo.id }) {
            todayTodos.remove(at: todayIndex)
            todoManager.saveTodayTodos(todayTodos)
            saveMostRecentTodo()
        }
    }
    
    private func increaseResistance(resistance: Int?) -> Int {
        var resistanceNew = resistance ?? 0
        if resistanceNew <= 10 {
            resistanceNew+=1
        }
        return resistanceNew
    }
    
    
    func getTotalEstimatedTime(defaultEstimatedTime: Int = 15) -> Int {
        return todayTodos.compactMap { todayTodo in
            if let todo = allTodos.first(where: { $0.id == todayTodo.todoId }) {
                let estimatedTime = todo.estimatedTime ?? defaultEstimatedTime
                return todo.isDone ? nil : estimatedTime
            }
            return nil
        }.reduce(0, +)
    }
    
    func setToDone(_ todo: Todo) {
        guard let index = allTodos.firstIndex(of: todo) else { return }
        allTodos[index].isDone = true
        todoManager.saveTodos(allTodos)
    }
    
    func updateTodo(_ updatedTodo: Todo) {
        if let index = allTodos.firstIndex(where: { $0.id == updatedTodo.id }) {
            allTodos[index] = updatedTodo
            todoManager.saveTodos(allTodos)
        }
    }
    
    func cloneTodo(todo: Todo) {
        let clonedTodo = Todo(id: UUID(), title: "\(Localization.labels.clone) - \(todo.title)", details: todo.details, dueDate: todo.dueDate, estimatedTime: todo.estimatedTime, isDone: false)
        allTodos.insert(clonedTodo, at: 0)
        todoManager.saveTodos(allTodos)
    }
    
    func deleteTodo(_ todo: Todo) {
        if let index = allTodos.firstIndex(where: { $0.id == todo.id }) {
            allTodos.remove(at: index)
            todoManager.saveTodos(allTodos)
        }
        
        if let todayIndex = todayTodos.firstIndex(where: { $0.todoId == todo.id }) {
            todayTodos.remove(at: todayIndex)
            todoManager.saveTodayTodos(todayTodos)
            saveMostRecentTodo()
        }
        
        DeviceFeedback.vibrate()
    }
    
    func isRecurringTaskInTodayTodos(_ recurringTaskId: UUID) -> Bool {
        return todayTodos.contains(where: { $0.recurringTaskId == recurringTaskId })
    }
    
    func saveMostRecentTodo() {
        if let firstTodayTodo = todayTodos.first {
            if let mostRecentTodoIndex = allTodos.firstIndex(where: { $0.id == firstTodayTodo.todoId }) {
                let mostRecentTodo = allTodos[mostRecentTodoIndex]
                todoManager.saveMostRecentTodo(mostRecentTodo)
            }
        }
    }
    
    func moveTodayTodos(from source: IndexSet, to destination: Int) {
        todayTodos.move(fromOffsets: source, toOffset: destination)
        todoManager.saveTodayTodos(todayTodos)
        saveMostRecentTodo()
    }
    
    func updateTodos() {
        todoManager.saveTodos(allTodos)
    }
    
    func randomTodo() -> Todo? {
        let availableTodos = allTodos.filter { !$0.isSelectedForToday }
        return availableTodos.randomElement()
    }

    func moveTodoOneDown(_ todo: Todo) {
        guard let currentIndex = allTodos.firstIndex(of: todo) else { return }

        allTodos[currentIndex].resistance = increaseResistance(resistance: todo.resistance)
        
        let newIndex = currentIndex + 1
        if newIndex < allTodos.count {
            allTodos.swapAt(currentIndex, newIndex)
            updateTodos()
        }
    }

    func moveToTheTop(_ todo: Todo) {
        selectForToday(todo)
        if let index = allTodos.firstIndex(of: todo) {
            allTodos.remove(at: index)
            allTodos.insert(todo, at: 0)
            updateTodos()
        }
    }
    
    func reorderTodayTodos() {
        todayTodos.sort { firstTodo, secondTodo in
             guard let first = allTodos.first(where: { $0.id == firstTodo.todoId }),
                   let second = allTodos.first(where: { $0.id == secondTodo.todoId }) else {
                 return false
             }

            // The completed todos to the end.
            if first.isDone && !second.isDone {
                return false
            } else if !first.isDone && second.isDone {
                return true
            } else if first.isDone && second.isDone {
                return first.dueDate ?? first.createdAt < second.dueDate ?? second.createdAt
            }
            
            // Todos with no estimated time to the top
             if first.estimatedTime == nil && second.estimatedTime != nil {
                 return true
             } else if first.estimatedTime != nil && second.estimatedTime == nil {
                 return false
             } else if first.estimatedTime == nil && second.estimatedTime == nil {
                 return first.dueDate ?? first.createdAt < second.dueDate ?? second.createdAt
             }

             if first.estimatedTime != second.estimatedTime {
                 return first.estimatedTime! < second.estimatedTime!
             } else {
                 return first.dueDate ?? first.createdAt < second.dueDate ?? second.createdAt
             }
         }

         todoManager.saveTodayTodos(todayTodos)
         saveMostRecentTodo()
        
    }

}
