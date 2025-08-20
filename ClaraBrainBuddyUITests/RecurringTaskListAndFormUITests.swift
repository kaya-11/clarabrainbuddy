//
//  RecurringTaskListAndFormUITests.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 07.08.25.
//


import XCTest
@testable import ClaraBrainBuddy

final class RecurringTaskListAndFormUITests: XCTestCase {
    
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        
        app.tabBars.buttons.element(boundBy: 2).tap()
    }

    func testRecurringTaskFlow() {
        addRecurringTask()
        editRecurringTask()
        checkRecurringTaskIsInTodaysTodoList()
        deleteRecurringTask()
    }
        
    func addRecurringTask() {
        
        let recurringTasksTab = app.otherElements["RecurringTaskTab"]
        let addButton = recurringTasksTab.buttons["AddRecurringTaskButton"]
        addButton.tap()
        
        let titleField = app.textFields.element(boundBy: 0)
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("Task Title")

        let detailsEditor = app.textViews.element(boundBy: 0)
        detailsEditor.tap()
        detailsEditor.typeText("Some additional details for this task")

        // Optionally fill estimated time
        let estimatedTimeField = app.textFields.element(boundBy: 1)
        estimatedTimeField.tap()
        estimatedTimeField.typeText("30")

        // Save
        let saveButton = app.buttons["TaskFormSaveButton"]
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()

        // Form should dismiss, return to list
        XCTAssertTrue(addButton.waitForExistence(timeout: 2))
    }
    
    func editRecurringTask() {
        
        let taskCell = app.staticTexts["Task Title"]
        XCTAssertTrue(taskCell.waitForExistence(timeout: 2))
        
        taskCell.swipeRight()
        app.buttons["RecurringTaskListViewEditTask"].tap()

        let titleField = app.textFields.element(boundBy: 0)
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.clearAndEnterText("Updated Task Title")

        let saveButton = app.buttons["TaskFormSaveButton"]
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()

        // Check we're back
        XCTAssertTrue(app.buttons["AddRecurringTaskButton"].waitForExistence(timeout: 2))
    }
    
    func checkRecurringTaskIsInTodaysTodoList() {
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        let taskCell = app.staticTexts["Updated Task Title"]
        XCTAssertTrue(taskCell.waitForExistence(timeout: 2))
        
        taskCell.swipeRight()
        
        let addTaskAsTodayTodoButton = app.buttons["AddRecurringTaskAsTodayTodoButton"]
        XCTAssertTrue(addTaskAsTodayTodoButton.exists)
        addTaskAsTodayTodoButton.tap()
        
        let todoCell = app.staticTexts["Updated Task Title"]
        XCTAssertTrue(todoCell.waitForExistence(timeout: 2))
        
        todoCell.swipeLeft()
        
        sleep(4)
        
        let removeTodoButton = app.buttons["TodaysTodosDeleteTodo"]
        XCTAssertTrue(removeTodoButton.exists)
        removeTodoButton.tap()
        
        XCTAssertTrue(taskCell.waitForExistence(timeout: 2))
        
        taskCell.swipeRight()
        
        XCTAssertTrue(addTaskAsTodayTodoButton.exists)
    }
    
    func deleteRecurringTask() {
        app.tabBars.buttons.element(boundBy: 2).tap()
        
        let taskCell = app.staticTexts["Updated Task Title"]
        XCTAssertTrue(taskCell.waitForExistence(timeout: 2))
        
        taskCell.swipeLeft()
        let button = app.buttons["RecurringTaskListDeleteTask"]
        XCTAssertTrue(button.waitForExistence(timeout: 2))
        button.tap()
        
        XCTAssertFalse(taskCell.waitForExistence(timeout: 2))

        XCTAssertTrue(app.buttons["AddRecurringTaskButton"].waitForExistence(timeout: 2))
    }
    
    func testSaveButtonDisabledWhenTitleEmpty() {
        let recurringTasksTab = app.otherElements["RecurringTaskTab"]
        let addButton = recurringTasksTab.buttons["AddRecurringTaskButton"]
        addButton.tap()

        let saveButton = app.buttons["TaskFormSaveButton"]
        XCTAssertFalse(saveButton.isEnabled)

        let titleField = app.textFields.element(boundBy: 0)
        titleField.tap()
        titleField.typeText("   ")

        XCTAssertFalse(saveButton.isEnabled)
    }
}
