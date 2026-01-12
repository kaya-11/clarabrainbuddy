//
//  CategoryViewModelTests.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 09.01.26.
//


import XCTest
import CoreData
@testable import ClaraBrainBuddy

final class CategoryViewModelTests: XCTestCase {

    var viewModel: CategoryViewModel!
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        context = DataManager.shared.context
        viewModel = CategoryViewModel(context: context)
        // Lösche alle bestehenden Kategorien vor jedem Test
        for (_, category) in viewModel.allCategories.enumerated() {
            context.delete(category)
        }
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testAddCategoryAddsCategoryAndSaves() {
        XCTAssertEqual(viewModel.allCategories.count, 0)

        viewModel.addCategory(name: "Test Category", color: "FF0000", isDefault: true)

        XCTAssertEqual(viewModel.allCategories.count, 1)
        XCTAssertEqual(viewModel.allCategories[0].name, "Test Category")
        XCTAssertEqual(viewModel.allCategories[0].color, "FF0000")
        XCTAssertTrue(viewModel.allCategories[0].isDefault)
    }

    func testResetIsDefault() {
        viewModel.addCategory(name: "Category 1", color: "FF0000", isDefault: true)
        let category1 : ClaraBrainBuddy.Category = viewModel.allCategories[0]
        
        XCTAssertTrue(category1.isDefault)
        
        viewModel.addCategory(name: "Category 2", color: "FF0000", isDefault: true)

        XCTAssertFalse(category1.isDefault)
        
        let category2 : ClaraBrainBuddy.Category = viewModel.allCategories[0]
        XCTAssertEqual(category2.name, "Category 2")
        XCTAssertTrue(category2.isDefault)
    }

    func testUpdateCategory() {
        let category = createCategory(name: "Old Name", isDefault: false)

        category.name = "New Name"
        category.isDefault = true
        viewModel.updateCategory(category)

        XCTAssertEqual(category.name, "New Name")
        XCTAssertTrue(category.isDefault)
    }

    func testCategoryExists() {
        _ = createCategory(name: "Test Category")
        
        XCTAssertTrue(viewModel.categoryExists(name: "Test Category"))
        XCTAssertFalse(viewModel.categoryExists(name: "Non Existent"))
        XCTAssertFalse(viewModel.categoryExists(name: nil))
    }
    
    func testGetCategoryByName() {
        let cat = createCategory(name: "Test Category")
        
        XCTAssertEqual(cat, viewModel.getCategoryByName(name: "Test Category"))
        XCTAssertNil(viewModel.getCategoryByName(name: "Non Existent"))
        XCTAssertNil(viewModel.getCategoryByName(name: nil))
    }

    func testDeleteCategory() {
        let category = createCategory(name: "Test Category")

        XCTAssertEqual(viewModel.allCategories.count, 1)
        viewModel.deleteCategory(category)
        XCTAssertEqual(viewModel.allCategories.count, 0)
    }

    func testMoveCategory() {
        _ = createCategory(name: "Category 1", sortOrder: 0)
        _ = createCategory(name: "Category 2", sortOrder: 1)

        XCTAssertEqual(viewModel.allCategories[0].name, "Category 1")
        XCTAssertEqual(viewModel.allCategories[1].name, "Category 2")

        viewModel.moveCategory(from: IndexSet(integer: 1), to: 0)

        XCTAssertEqual(viewModel.allCategories[0].name, "Category 2")
        XCTAssertEqual(viewModel.allCategories[1].name, "Category 1")
    }

    func testHasReachedMaxNumberOfCategories() {
        for i in 0..<CategoryViewModel.MAX_NUMBER_OF_CATEGORIES {
            _ = createCategory(name: "Category \(i)")
        }

        XCTAssertTrue(viewModel.hasReachedMaxNumberOfCategories())
    }
    
    func testGetDefaultCategoryNoneAvailable() {
        XCTAssertEqual(viewModel.getDefaultCategory(), nil)
    }
    
    
    func testGetDefaultCategoryNoneSetAsDefault() {
        _ = createCategory(name: "Test Category")
        XCTAssertEqual(viewModel.getDefaultCategory(), nil)
    }
    
    func testGetDefaultCategory() {
        let cat = createCategory(name: "Test Category", isDefault: true)
        XCTAssertEqual(viewModel.getDefaultCategory(), cat)
    }
    
    func testHasNoneCategories() {
        XCTAssertFalse(viewModel.hasCategories())
    }
    
    func testHasCategories() {
        _ = createCategory(name: "Test Category")
        XCTAssertTrue(viewModel.hasCategories())
    }

    private func createCategory(
        name: String,
        color: String = "FF0000",
        isDefault: Bool = false,
        sortOrder: Int64 = 0
    ) -> ClaraBrainBuddy.Category {
        let category = ClaraBrainBuddy.Category(context: context)
        category.name = name
        category.color = color
        category.isDefault = isDefault
        category.sortOrder = sortOrder
        category.createdAt = Date()
        try? context.save()
        return category
    }
}
