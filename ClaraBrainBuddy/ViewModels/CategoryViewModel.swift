//
//  ViewModels/TodoViewModel.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//

import Foundation
import CoreData

class CategoryViewModel: ObservableObject {
    
    static let MAX_NUMBER_OF_CATEGORIES = 12
   
    private let context: NSManagedObjectContext

    static let shared = CategoryViewModel(context: DataManager.shared.context)
    
    static let MAX_LENGTH_CATEGORY_NAME: Int = 30
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }

    var allCategories: [Category] {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.sortOrder, ascending: true)]
        
        var allCategories = [] as [Category]
        do {
            allCategories = try context.fetch(request)
        } catch {
            print("Failed to fetch categories: \(error)")
        }
        return allCategories
        
    }

    func addCategory(name: String, color: String, isDefault: Bool?) {
    
        let newCategory = Category(context: context)
        newCategory.name = name
        newCategory.color = color // check if is valid Color
        newCategory.createdAt = Date()
        newCategory.sortOrder = 0
        newCategory.isDefault = isDefault ?? false
        
        resetIsDefault(newCategory)
        
        var reorderedCategories = allCategories
        reorderedCategories.insert(newCategory, at: 0)
        
        for (index, category) in reorderedCategories.enumerated() {
            category.sortOrder = Int64(index)
        }

        saveContext()
    }
    
    fileprivate func resetIsDefault(_ category: Category) {
        if (category.isDefault == true) {
            for cat in allCategories {
                if cat != category {
                    cat.isDefault = false
                }
            }
        }
    }
    
    func updateCategory(_ updatedCategory: Category) {
        resetIsDefault(updatedCategory)
        updatedCategory.updatedAt = Date()
        saveContext()
    }

    func categoryExists(name: String?) -> Bool {
        guard let name = name else { return false }
        return allCategories.contains { $0.name.lowercased() == name.lowercased() }
    }

    func getCategoryByName(name: String?) -> Category? {
        guard let name = name else { return nil }
        return allCategories.filter { $0.name.lowercased() == name.lowercased() }.first
    }
    
    func deleteCategory(_ category: Category)  throws {
        if (isCategoryUnused(category: category)) {
            context.delete(category)
            saveContext()
        } else {
            throw CategoryModelError.deletion
        }
    }

    func moveCategory(from source: IndexSet, to destination: Int) {
        var reorderedCategories = allCategories
        reorderedCategories.move(fromOffsets: source, toOffset: destination)
        
        for (index, category) in reorderedCategories.enumerated() {
            category.sortOrder = Int64(index)
        }
        
        saveContext()
    }

    func hasReachedMaxNumberOfCategories() -> Bool {
        return allCategories.count >= CategoryViewModel.MAX_NUMBER_OF_CATEGORIES
    }
    
    func getDefaultCategory() -> Category? {
        return allCategories.first { category in
            category.isDefault
        }
    }
    
    func hasCategories() -> Bool {
        return !allCategories.isEmpty
    }
    
    func isCategoryUnused(category: Category) -> Bool {
        return category.todos.isEmpty && category.recurringTasks.isEmpty
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}

enum CategoryModelError: Error, LocalizedError {
    case deletion
    var errorDescription: String? {
        switch self {
        case .deletion:
            return NSLocalizedString(Localization.errors.deletionErrorTitle, comment: "Deletion Not Possible")
        }
    }
}
