//
//  ViewModels/TodoViewModel.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//

import Foundation

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
        addNewTodoForToday(title: recurringTask.title, details: recurringTask.details ?? "", estimatedTime: nil, recurringTaskId: recurringTask.id)
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
            todoManager.saveTodos(allTodos)
        }
        
        if let todayIndex = todayTodos.firstIndex(where: { $0.todoId == todo.id }) {
            todayTodos.remove(at: todayIndex)
            todoManager.saveTodayTodos(todayTodos)
            saveMostRecentTodo()
        }
    }
    
    
    func getTotalEstimatedTime() -> Int {
        return todayTodos.compactMap { todayTodo in
            if let todo = allTodos.first(where: { $0.id == todayTodo.todoId }) {
                let estimatedTime = todo.estimatedTime ?? 15
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
    
    func reorderTodayTodos(from source: IndexSet, to destination: Int) {
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

}
