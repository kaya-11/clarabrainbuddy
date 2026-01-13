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
    
    @NSManaged public var details: String?
    @NSManaged public var estimatedTime_: Int64
    @NSManaged public var recurrenceRuleAsString: String
    @NSManaged public var sortOrder: Int64
    @NSManaged public var title: String
    @NSManaged public var category: Category?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date?
}

extension RecurringTask : Identifiable {
    
    var estimatedTime: Int64? {
        get { return estimatedTime_ == -1 ? nil : estimatedTime_ }
        set { estimatedTime_ = newValue ?? -1 }
    }
    
    var recurrenceRule: RecurrenceRule {
        get { RecurrenceRule.decode(from: recurrenceRuleAsString) ?? .daily }
        set { recurrenceRuleAsString = newValue.encoded() }
    }
}
