//
//  Models/Todo.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//
import Foundation

struct Todo: Identifiable, Codable, Hashable {
    let id : UUID
    var title: String
    var details: String?
    var dueDate: Date?
    var estimatedTime: Int? // in minutes
    var isSelectedForToday: Bool = false
    var isDone: Bool = false
    var resistance: Int? = 0
    var createdAt = Date()
    var updatedAt = Date()
    
    func getDetails() -> String {
        var taskDescription = title

        // Append details if it is not nil or empty
        if let details = details, !details.isEmpty {
            taskDescription += "\n" + details
        }

        return taskDescription
    }
}
