//
//  Todo+CoreDataProperties.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 15.08.25.
//
//

import Foundation
import CoreData

extension Todo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Todo> {
        return NSFetchRequest<Todo>(entityName: "Todo")
    }

    @NSManaged public var title: String
    @NSManaged public var details: String?
    @NSManaged public var dueDate: Date
    @NSManaged public var estimatedTime_: Int64
    @NSManaged public var energyImpact: Int64
    @NSManaged public var isDone: Bool
    @NSManaged public var resistance: Int64
    @NSManaged public var selectedForToday: Bool
    @NSManaged public var sortOrder: Int64
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date?

}

extension Todo : Identifiable {
    
    var estimatedTime: Int64? {
        get { return estimatedTime_ == -1 ? nil : estimatedTime_ }
        set { estimatedTime_ = newValue ?? -1 }
    }
    var isOverdue: Bool {
        return dueDate < DateUtils.getDateSevenDaysBeforeNow()
    }
    
    var isDueSoon: Bool {
        return dueDate < DateUtils.getDateThreeDaysFromNow()
    }
    
    var fullTodoDescription : String {
        var todoDescription = title

        // Append details if it is not nil or empty
        if let details = details, !details.isEmpty {
            todoDescription += "\n" + details
        }

        return todoDescription
    }
    
    func toDto() -> TodoDto {
        return TodoDto(
            title: title ,
            details: details,
            dueDate: dueDate,
            estimatedTime: estimatedTime,
            energyImpact: energyImpact,
            selectedForToday: selectedForToday,
            isDone: isDone,
            resistance: resistance,
            createdAt: createdAt,
            updatedAt: updatedAt ?? Date()
        )
    }
    
    func populate(from dto: TodoDto, context: NSManagedObjectContext) {
        title = dto.title
        details = dto.details
        dueDate = dto.dueDate
        estimatedTime = dto.estimatedTime.map { Int64($0.clamped(to: 0...1440)) }
        energyImpact = dto.energyImpact.map { Int64($0.clamped(to: -1...1)) } ?? 0
        selectedForToday = dto.selectedForToday
        isDone = dto.isDone
        resistance = dto.resistance.clamped(to: 0...10)
        createdAt = dto.createdAt
        updatedAt = dto.updatedAt
    }
}
