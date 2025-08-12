//
//  RecurringTask+CoreDataProperties.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 15.08.25.
//
//

import Foundation
import CoreData

extension RecurringTask {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecurringTask> {
        return NSFetchRequest<RecurringTask>(entityName: "RecurringTask")
    }
    
    @NSManaged public var createdAt: Date
    @NSManaged public var details: String?
    @NSManaged public var estimatedTime: Int64
    @NSManaged public var id: UUID
    @NSManaged public var recurrenceRuleAsString: String
    @NSManaged public var sortOrder: Int64
    @NSManaged public var title: String
    @NSManaged public var updatedAt: Date?
}

extension RecurringTask : Identifiable {
    var recurrenceRule: RecurrenceRule {
        get { RecurrenceRule.decode(from: recurrenceRuleAsString) ?? .daily }
        set { recurrenceRuleAsString = newValue.encoded() }
    }
}
