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
    
    func addNewTodoForToday(title: String, details: String, estimatedTime: Int?) {
        let newTodo = Todo(
            id: UUID(),
            title: title,
            details: details,
            dueDate: Date(),
            estimatedTime: estimatedTime
        )
        allTodos.insert(newTodo, at: 0)
        selectForToday(newTodo)
    }
    
    func selectForToday(_ todo: Todo) {
        guard let index = allTodos.firstIndex(of: todo) else { return }
        
        allTodos[index].isSelectedForToday = true

        let alreadyInToday = todayTodos.contains(where: { $0.todoId == todo.id })
        if !alreadyInToday {
            let newTodayTodo = TodayTodo(id: UUID(), todoId: todo.id)
            todayTodos.append(newTodayTodo)
        }

        todoManager.saveTodos(allTodos)
        todoManager.saveTodayTodos(todayTodos)
    }

    func deselectForToday(_ todo: Todo) {
        if let todoIndex = allTodos.firstIndex(of: todo) {
            allTodos[todoIndex].isSelectedForToday = false
            todoManager.saveTodos(allTodos)
        }
        
        if let todayIndex = todayTodos.firstIndex(where: { $0.todoId == todo.id }) {
            todayTodos.remove(at: todayIndex)
            todoManager.saveTodayTodos(todayTodos)
        }
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
        }
    }
    
    func reorderTodayTodos(from source: IndexSet, to destination: Int) {
        todayTodos.move(fromOffsets: source, toOffset: destination)
        todoManager.saveTodayTodos(todayTodos)
    }
    
    func updateTodos() {
        todoManager.saveTodos(allTodos)
    }
    
    func randomTodo() -> Todo? {
        return allTodos.randomElement()
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
