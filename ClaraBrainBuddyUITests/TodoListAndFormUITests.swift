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
        deleteTodoFlow()
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
    
    func deleteTodoFlow() {
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
    


}

extension XCUIElement {
    func clearAndEnterText(_ text: String) {
        guard let stringValue = self.value as? String else {
            self.tap()
            self.typeText(text)
            return
        }

        self.tap()

        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
        self.typeText(text)
    }
}
