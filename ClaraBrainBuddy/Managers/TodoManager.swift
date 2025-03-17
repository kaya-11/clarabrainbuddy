//
//  Managers/TodoManager.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//

import Foundation

class TodoManager {
    private let todosKey = "todos"
    private let todayTodosKey = "todays_todos"

    func saveTodos(_ todos: [Todo]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(todos) {
            UserDefaults.standard.set(encoded, forKey: todosKey)
        }
    }

    func loadTodos() -> [Todo] {
        if let data = UserDefaults.standard.data(forKey: todosKey) {
            let decoder = JSONDecoder()
            if let todos = try? decoder.decode([Todo].self, from: data) {
                return todos
            }
        }
        return []
    }
    
    func saveTodayTodos(_ todayTodos: [TodayTodo]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(todayTodos) {
            UserDefaults.standard.set(encoded, forKey: todayTodosKey)
        }
    }
    
    func loadTodayTodos() -> [TodayTodo] {
        if let data = UserDefaults.standard.data(forKey: todayTodosKey) {
            let decoder = JSONDecoder()
            if let todos = try? decoder.decode([TodayTodo].self, from: data) {
                return todos
            }
        }
        return []
    }
}
