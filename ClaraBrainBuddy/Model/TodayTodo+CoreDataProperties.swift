//
//  TodayTodo+CoreDataProperties.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 15.08.25.
//
//

import Foundation
import CoreData


extension TodayTodo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodayTodo> {
        return NSFetchRequest<TodayTodo>(entityName: "TodayTodo")
    }

    @NSManaged public var selectedForTodayAt: Date
    @NSManaged public var sortOrder: Int64
    @NSManaged public var recurringTask: RecurringTask?
    @NSManaged public var todo: Todo
    @NSManaged public var updatedAt: Date?

}

extension TodayTodo : Identifiable {

}
