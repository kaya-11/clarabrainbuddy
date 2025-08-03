//
//  Models/RecurrentTodo.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 18.03.25.
//
import Foundation

enum RecurrenceRule: Codable, Hashable {
    case daily
    case weekly(weekday: Int) // 1=Sunday ... 7=Saturday
    case monthly(day: Int) // z.B. 15. jeden Monats
    case evenDays 
    case oddDays
}

struct RecurringTask: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var details: String?
    var estimatedTime: Int? // in minutes
    var recurrenceRule: RecurrenceRule
    
    init(id: UUID = UUID(),
         title: String,
         details: String? = nil,
         estimatedTime: Int? = nil,
         recurrenceRule: RecurrenceRule = RecurrenceRule.daily) {
            self.id = id
            self.title = title
            self.details = details
            self.estimatedTime = estimatedTime
            self.recurrenceRule = recurrenceRule
    }
}
