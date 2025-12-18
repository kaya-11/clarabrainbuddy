//
//  ViewModels/TodoViewModel.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//

import Foundation
import CoreData

class CategoryViewModel: ObservableObject {
   
    private let context: NSManagedObjectContext

    static let shared = CategoryViewModel(context: DataManager.shared.context)
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }

    var allCategoriess: [Category] {
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
        
        var reorderedCategories = allCategoriess
        reorderedCategories.insert(newCategory, at: 0)
        
        for (index, category) in reorderedCategories.enumerated() {
            category.sortOrder = Int64(index)
        }

        saveContext()
    }
    
    fileprivate func resetIsDefault(_ category: Category) {
        if (category.isDefault == true) {
            for cat in allCategoriess {
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

    func deleteCategory(_ category: Category) {
        // TODO Nur löschen, wenn es keine Todos mit der Category gibt
        context.delete(category)
        saveContext()
    }

    func moveCategory(from source: IndexSet, to destination: Int) {
        var reorderedCategories = allCategoriess
        reorderedCategories.move(fromOffsets: source, toOffset: destination)
        
        for (index, category) in reorderedCategories.enumerated() {
            category.sortOrder = Int64(index)
        }
        
        saveContext()
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
