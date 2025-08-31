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
        
        app.tabBars.buttons.element(boundBy: 0).tap()
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

        // Optionally fill estimated time
        let estimatedTimeField = app.textFields.element(boundBy: 1)
        estimatedTimeField.tap()
        estimatedTimeField.typeText("30")

        // Save
        let saveButton = app.buttons["TodoFormSaveButton"]
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
        

}
