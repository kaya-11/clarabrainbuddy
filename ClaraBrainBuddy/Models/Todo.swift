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
    
    init(id: UUID = UUID(), title: String, details: String? = nil, dueDate: Date? = nil, estimatedTime: Int? = nil, isSelectedForToday: Bool = false, isDone: Bool = false, resistance: Int? = 0) {
        self.id = id
        self.title = title
        self.details = details
        self.dueDate = dueDate
        self.estimatedTime = estimatedTime
        self.isSelectedForToday = isSelectedForToday
        self.isDone = isDone
        self.resistance = resistance
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    func getDetails() -> String {
        var taskDescription = title

        // Append details if it is not nil or empty
        if let details = details, !details.isEmpty {
            taskDescription += "\n" + details
        }

        return taskDescription
    }
    
    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return dueDate < DateUtils.getDateSevenDaysBeforeNow()
    }
    
    var isDueSoon: Bool {
        guard let dueDate = dueDate else { return false }
        return dueDate < DateUtils.getDateThreeDaysFromNow()
    }
}
