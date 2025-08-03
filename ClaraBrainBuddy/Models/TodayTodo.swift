//
//  Models/TodayTodo.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 18.03.25.
//
import Foundation

struct TodayTodo: Identifiable,  Codable  {
    let id: UUID
    var todoId: UUID?
    var recurringTaskId: UUID?
    
    init(id: UUID = UUID(), todoId: UUID, recurringTaskId: UUID? = nil) {
        self.id = id
        self.todoId = todoId
        self.recurringTaskId = recurringTaskId
    }
}
