//
//  Category+CoreDataProperties.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 15.08.25.
//
//

import Foundation
import CoreData
import SwiftUI

extension Category {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date?
    @NSManaged public var name: String
    @NSManaged public var sortOrder: Int64
    @NSManaged public var isDefault: Bool
    @NSManaged public var color: String
    @NSManaged public var todos: Set<Todo>
    @NSManaged public var recurringTasks: Set<Todo>
}

extension Category : Identifiable {
    func toDto() -> CategoryDto {
        return CategoryDto(name: name)
    }
}
