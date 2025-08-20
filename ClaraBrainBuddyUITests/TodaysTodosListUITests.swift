//
//  TodaysTodosListUITests.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 07.08.25.
//


import XCTest
@testable import ClaraBrainBuddy

final class TodaysTodosListUITests: XCTestCase {
    
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        
        app.tabBars.buttons.element(boundBy: 1).tap()
    }

    func testTodayTodoFlow() {
        addTodo()
        removeFromTodaysTodo()
        markForToday()
        markAsDone()
        deleteTodoFlow()
    }
        
    func addTodo() {
        
        let todayTab = app.otherElements["TodayTab"]
        let addButton = todayTab.buttons["AddTodayTodoButton"]
        addButton.tap()
        
        let titleField = app.textFields.element(boundBy: 0)
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("Test Today Todo")

        // Save
        let saveButton = app.buttons["TodaysTodoFormSaveButton"]
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()

        // Form should dismiss, return to list
        XCTAssertTrue(addButton.waitForExistence(timeout: 2))
    }
    
    func removeFromTodaysTodo() {
        let todoCell = app.staticTexts["Test Today Todo"]
        XCTAssertTrue(todoCell.waitForExistence(timeout: 2))
        
        todoCell.swipeLeft()
        app.buttons["RemoveFromTodaysTodos"].tap()
        
        XCTAssertFalse(todoCell.waitForExistence(timeout: 2))
        
        let todayTab = app.otherElements["TodayTab"]
        let addButton = todayTab.buttons["AddTodayTodoButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 2))
    }
    
    func markForToday() {
        
        app.tabBars.buttons.element(boundBy: 0).tap()
        
        let todoCell = app.staticTexts["Test Today Todo"]
        XCTAssertTrue(todoCell.waitForExistence(timeout: 2))
        
        todoCell.swipeRight()
        app.buttons["MarkForToday"].tap()
        
        XCTAssertTrue(todoCell.waitForExistence(timeout: 2))
        
        app.tabBars.buttons.element(boundBy: 1).tap()

        let todayTab = app.otherElements["TodayTab"]
        let addButton = todayTab.buttons["AddTodayTodoButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 2))
    }
    
    func markAsDone() {
        
        let todoCell = app.staticTexts["Test Today Todo"]
        XCTAssertTrue(todoCell.waitForExistence(timeout: 2))
        
        // mark as done
        todoCell.swipeRight()
        app.buttons["MarkAsDoneButton"].tap()
        
        XCTAssertEqual(todoCell.value as? String, "done")
        
        let todayTab = app.otherElements["TodayTab"]
        let addButton = todayTab.buttons["AddTodayTodoButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 2))
    }
    
    func deleteTodoFlow() {
        sleep(4)
        
        let todoCell = app.staticTexts["Test Today Todo"]
        XCTAssertTrue(todoCell.waitForExistence(timeout: 2))
        
        todoCell.swipeLeft()
        let deleteButton = app.buttons["TodaysTodosDeleteTodo"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 2))
        deleteButton.tap()
        
        XCTAssertFalse(todoCell.waitForExistence(timeout: 2))

        let todayTab = app.otherElements["TodayTab"]
        let addButton = todayTab.buttons["AddTodayTodoButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 2))
    }

}
