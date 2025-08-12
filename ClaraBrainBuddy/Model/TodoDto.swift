//
//  Model/TodoDto.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//

import Foundation

struct TodoDto: Identifiable, Codable, Hashable {
    let id : UUID 
    var title: String = ""
    var details: String?
    var dueDate: Date = Date()
    var estimatedTime: Int64? // in minutes
    var selectedForToday: Bool = false
    var isDone: Bool = false
    var resistance: Int64
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    init(
        id: UUID = UUID(),
        title: String,
        details: String? = nil,
        dueDate: Date = Date(),
        estimatedTime: Int64? = nil,
        selectedForToday: Bool = false,
        isDone: Bool = false,
        resistance: Int64 = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.details = details
        self.dueDate = dueDate
        self.estimatedTime = estimatedTime
        self.selectedForToday = selectedForToday
        self.isDone = isDone
        self.resistance = resistance
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
