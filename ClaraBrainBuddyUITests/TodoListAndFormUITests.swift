//
//  TodoListAndFormUITests.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 07.08.25.
//


import XCTest
@testable import ClaraBrainBuddy

final class TodoListAndFormUITests: XCTestCase {
    
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        
        app.tabBars.buttons[UITestUtils.TabNames.all].tap()
    }
    
    func testTodoFlow() {
        addTodo()
        editTodo()
        deleteTodoAndCheck()
    }

    func addTodo() {
        
        let allTodosTab = app.otherElements["AllTodosTab"]
        let addButton = allTodosTab.buttons["AddTodoButton"]
        addButton.tap()
        
        let titleField = app.textFields.element(boundBy: 0)
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("Test Todo")

        let detailsEditor = app.textViews.element(boundBy: 0)
        detailsEditor.tap()
        detailsEditor.typeText("Some additional details for this todo")
        
        let dueDateField = app.datePickers["TodoFormDueDateField"]
        dueDateField.tap()

        let estimatedTimeField = app.textFields["TodoFormEstimatedTimeField"]
        
        sleep(2)
        XCTAssertTrue(estimatedTimeField.waitForExistence(timeout: 2))
        
        // Hilfskontrukt um nach unten zu scrollen
        let saveButton = app.buttons["TodoFormSaveButton"]
        while !saveButton.isHittable {
            app.swipeUp()
        }
        
        estimatedTimeField.tap()
        
        estimatedTimeField.typeText("30")
        
        

        // Save
        while !saveButton.isHittable {
            app.swipeUp()
        }

        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()

        // Form should dismiss, return to list
        XCTAssertTrue(addButton.waitForExistence(timeout: 2))
    }
    
    func editTodo() {
        
        let todoCell = app.staticTexts["Test Todo"]
        XCTAssertTrue(todoCell.waitForExistence(timeout: 2))
        
        todoCell.swipeRight()
        app.buttons["TodoListViewEditTodo"].tap()

        let titleField = app.textFields.element(boundBy: 0)
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.clearAndEnterText("Updated Todo Title")
        
        let saveButton = app.buttons["TodoFormSaveButton"]
        while !saveButton.isHittable {
            app.swipeUp()
        }
        
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()

        // Check we're back
        XCTAssertTrue(app.buttons["AddTodoButton"].waitForExistence(timeout: 2))
    }
    
    func deleteTodoAndCheck() {
        let todoCell = app.staticTexts["Updated Todo Title"]
        XCTAssertTrue(todoCell.waitForExistence(timeout: 2))
        
        todoCell.swipeLeft()
        app.buttons["TodoListDeleteTodo"].tap()
        
        XCTAssertFalse(todoCell.waitForExistence(timeout: 2))

        XCTAssertTrue(app.buttons["AddTodoButton"].waitForExistence(timeout: 2))
    }
    
    func testSaveButtonDisabledWhenTitleEmpty() {
        let allTodosTab = app.otherElements["AllTodosTab"]
        let addButton = allTodosTab.buttons["AddTodoButton"]
        addButton.tap()

        let saveButton = app.buttons["TodoFormSaveButton"]
        XCTAssertFalse(saveButton.isEnabled)

        let titleField = app.textFields.element(boundBy: 0)
        titleField.tap()
        titleField.typeText("   ")

        XCTAssertFalse(saveButton.isEnabled)
    }
    
    func testEnergyImpactSlider() {
        let allTodosTab = app.otherElements["AllTodosTab"]
        let addButton = allTodosTab.buttons["AddTodoButton"]
        addButton.tap()
        
        let saveButton = app.buttons["TodoFormSaveButton"]
        
        let titleField = app.textFields.element(boundBy: 0)
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("Todo EnergyImpact")
        
        sleep(2)
        
        while !saveButton.isHittable {
            app.swipeUp()
        }

        let energyImpactSlider = app.sliders["TodoFormEnergyImpactField"]
        XCTAssertTrue(energyImpactSlider.waitForExistence(timeout: 2))
        
        sleep(1)

        energyImpactSlider.adjust(toNormalizedSliderPosition: 0)

        sleep(1)

        energyImpactSlider.adjust(toNormalizedSliderPosition: 1)
        
        sleep(1)

        energyImpactSlider.adjust(toNormalizedSliderPosition: 0.5)
        
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()

        XCTAssertTrue(addButton.waitForExistence(timeout: 2))

        sleep(2)
        
        let todoCell = app.staticTexts["Todo EnergyImpact"]
        XCTAssertTrue(todoCell.waitForExistence(timeout: 2))
        
        let start = todoCell.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5))
        let end = todoCell.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.5))
        start.press(forDuration: 0.1, thenDragTo: end)
        
        print(app.debugDescription)
        
        let button = app.buttons["TodoListDeleteTodo"]
        XCTAssertTrue(button.waitForExistence(timeout: 2))
        
        button.tap()
    }

    func testAddTwoTodosAndDelete() {
        let allTodosTab = app.otherElements["AllTodosTab"]
        let addButton = allTodosTab.buttons["AddTodoButton"]
        addButton.tap()
        
        let titleField = app.textFields.element(boundBy: 0)
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("Todo1")

        let saveButton = app.buttons["TodoFormSaveButton"]
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()

        XCTAssertTrue(addButton.waitForExistence(timeout: 2))
        addButton.tap()
        
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("Todo2")

        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()

        XCTAssertTrue(addButton.waitForExistence(timeout: 2))

        sleep(2)
        
        var todoCell = app.staticTexts["Todo1"]
        XCTAssertTrue(todoCell.waitForExistence(timeout: 2))
        
        var start = todoCell.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5))
        var end = todoCell.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.5))
        start.press(forDuration: 0.1, thenDragTo: end)
        
        print(app.debugDescription)
        
        var button = app.buttons["TodoListDeleteTodo"]
        XCTAssertTrue(button.waitForExistence(timeout: 2))
        
        button.tap()
        
        XCTAssertFalse(todoCell.waitForExistence(timeout: 2))
        
        todoCell = app.staticTexts["Todo2"]
        XCTAssertTrue(todoCell.waitForExistence(timeout: 2))
        
        start = todoCell.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5))
        end = todoCell.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.5))
        start.press(forDuration: 0.1, thenDragTo: end)
        
        button = app.buttons["TodoListDeleteTodo"]
        XCTAssertTrue(button.waitForExistence(timeout: 2))
        button.tap()
        
        XCTAssertFalse(todoCell.waitForExistence(timeout: 2))

        XCTAssertTrue(app.buttons["AddTodoButton"].waitForExistence(timeout: 2))
    }
    
    func testAddTwoTodosAndReorder() {
        let allTodosTab = app.otherElements["AllTodosTab"]
        let addButton = allTodosTab.buttons["AddTodoButton"]
        addButton.tap()
        
        let titleField = app.textFields.element(boundBy: 0)
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("Todo1")
        
        let saveButton = app.buttons["TodoFormSaveButton"]
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()

        XCTAssertTrue(addButton.waitForExistence(timeout: 2))
        addButton.tap()
        
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("Todo2")

        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()

        XCTAssertTrue(addButton.waitForExistence(timeout: 2))
        
        sleep(2)
        let reorderButton = app.buttons["ReorderTodos"]
        
        XCTAssertTrue(reorderButton.waitForExistence(timeout: 2))
        reorderButton.tap()
        
        sleep(2)
        
        let todoCell1 = app.staticTexts["Todo1"]
        XCTAssertTrue(todoCell1.waitForExistence(timeout: 2))
        
        let start1 = todoCell1.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5))
        let end1 = todoCell1.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.5))
        
        let todoCell2 = app.staticTexts["Todo2"]
        XCTAssertTrue(todoCell2.waitForExistence(timeout: 2))
        
        let start2 = todoCell2.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5))
        let end2 = todoCell2.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.5))
        
        XCTAssertTrue(start1.screenPoint.y < start2.screenPoint.y)

        start1.press(forDuration: 0.1, thenDragTo: end1)
        
        var button = app.buttons["TodoListDeleteTodo"]
        XCTAssertTrue(button.waitForExistence(timeout: 2))
        
        button.tap()

        start2.press(forDuration: 0.1, thenDragTo: end2)

        button = app.buttons["TodoListDeleteTodo"]
        XCTAssertTrue(button.waitForExistence(timeout: 2))
        button.tap()
        
        XCTAssertFalse(todoCell2.waitForExistence(timeout: 2))
        
        XCTAssertTrue(app.buttons["AddTodoButton"].waitForExistence(timeout: 2))
    }
        
    func testSearchBarExists() throws {
        sleep(3)

        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
    }
    
    func testSearchFunctionality() throws {
        
        addTodo()
        
        let allTodosTab = app.otherElements["AllTodosTab"]
        let addButton = allTodosTab.buttons["AddTodoButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 2))
        addButton.tap()
        
        let titleField = app.textFields.element(boundBy: 0)
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("Todo Zwei")

        let saveButton = app.buttons["TodoFormSaveButton"]
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()
        
        sleep(3)

        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
        
        searchField.tap()

        searchField.typeText("Test")
        
        let todoCellFound = app.staticTexts["Test Todo"]
        XCTAssertTrue(todoCellFound.waitForExistence(timeout: 2))
        
        let todoCellNotFound = app.staticTexts["Todo Zwei"]
        XCTAssertFalse(todoCellNotFound.waitForExistence(timeout: 2))
        
        sleep(2)
        
        searchField.clearAndEnterText("")

        sleep(2)
        
        XCTAssertTrue(todoCellFound.waitForExistence(timeout: 2))
        XCTAssertTrue(todoCellNotFound.waitForExistence(timeout: 2))
        
        var start = todoCellFound.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5))
        var end = todoCellFound.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.5))
        start.press(forDuration: 0.1, thenDragTo: end)
        
        var deleteButton = app.buttons["TodoListDeleteTodo"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 2))
        deleteButton.tap()
        
        start = todoCellNotFound.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5))
        end = todoCellNotFound.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.5))
        start.press(forDuration: 0.1, thenDragTo: end)
        
        deleteButton = app.buttons["TodoListDeleteTodo"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 2))
        deleteButton.tap()
        
    }
    
    func testCheckCategoryPickerNotExistWithoutCategory() {
        
        let allTodosTab = app.otherElements["AllTodosTab"]
        let addButton = allTodosTab.buttons["AddTodoButton"]
        addButton.tap()
        
        let category = app.buttons["TodoFormCategoryPicker"]
        XCTAssertFalse(category.waitForExistence(timeout: 2))
    }

}
