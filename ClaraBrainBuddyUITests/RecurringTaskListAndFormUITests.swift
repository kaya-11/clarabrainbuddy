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
        
        app.tabBars.buttons[UITestUtils.TabNames.recurring].tap()
    }

    func testRecurringTaskFlow() {
        addRecurringTask()
        editRecurringTask()
        checkRecurringTaskIsInTodaysTodoListAndAddTodo()
        removeTodoAndCheck()
        deleteRecurringTask()
    }

    func testRecurringTaskFlowDeleteTaskWhenTodoWithReferenceExists() {
        addRecurringTask()
        editRecurringTask()
        checkRecurringTaskIsInTodaysTodoListAndAddTodo()
        deleteRecurringTask()
        removeTodo()
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
        
        let recurrenceRulePicker = app.buttons["RecurrTaskFormRulePicker"]
        
        XCTAssertTrue(recurrenceRulePicker.waitForExistence(timeout: 5))
        
        while !recurrenceRulePicker.isHittable {
            app.swipeUp()
        }
        recurrenceRulePicker.tap()

        // Optionally fill estimated time
        let estimatedTimeField = app.textFields["RecurringTaskFormEstimatedTimeField"]
        
        XCTAssertTrue(estimatedTimeField.waitForExistence(timeout: 2))
        
        while !estimatedTimeField.isHittable {
            app.swipeUp()
        }
        
        estimatedTimeField.tap()
        
        estimatedTimeField.clearAndEnterText("30")

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
    
    func checkRecurringTaskIsInTodaysTodoListAndAddTodo() {
        app.tabBars.buttons[UITestUtils.TabNames.today].tap()
        
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
    }
        
    func removeTodoAndCheck() {
        
        let taskCell = app.staticTexts["Updated Task Title"]
        XCTAssertTrue(taskCell.waitForExistence(timeout: 2))
        
        app.tabBars.buttons[UITestUtils.TabNames.today].tap()
        
        let removeTodoButton = app.buttons["TodaysTodosDeleteTodo"]
        XCTAssertTrue(removeTodoButton.exists)
        removeTodoButton.tap()
        
        XCTAssertTrue(taskCell.waitForExistence(timeout: 2))
        
        taskCell.swipeRight()
        
        let addTaskAsTodayTodoButton = app.buttons["AddRecurringTaskAsTodayTodoButton"]
        XCTAssertTrue(addTaskAsTodayTodoButton.exists)
    }
    
    func removeTodo() {

        app.tabBars.buttons[UITestUtils.TabNames.today].tap()
        
        let removeTodoButton = app.buttons["TodaysTodosDeleteTodo"]
        XCTAssertTrue(removeTodoButton.exists)
        removeTodoButton.tap()
        
        let noTodosLabel = app.staticTexts["Keine Aufgaben für heute geplant"]
        XCTAssertTrue(noTodosLabel.exists)
    }
    
    
    func deleteRecurringTask() {
        app.tabBars.buttons[UITestUtils.TabNames.recurring].tap()
        
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
    
    func testAddMoreThanOneRecurringTaskAndDeleteThem() {
        
        let recurringTasksTab = app.otherElements["RecurringTaskTab"]
        let addButton = recurringTasksTab.buttons["AddRecurringTaskButton"]
        addButton.tap()
        
        let titleField = app.textFields.element(boundBy: 0)
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("Task1")

        // Save
        let saveButton = app.buttons["TaskFormSaveButton"]
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()

        addButton.tap()
        
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("Task2")

        // Save
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()
        
        // Form should dismiss, return to list
        XCTAssertTrue(addButton.waitForExistence(timeout: 2))
        
        var taskCell = app.staticTexts["Task1"]
        XCTAssertTrue(taskCell.waitForExistence(timeout: 2))
        
        taskCell.swipeLeft()
        let button = app.buttons["RecurringTaskListDeleteTask"]
        XCTAssertTrue(button.waitForExistence(timeout: 2))
        button.tap()
        
        XCTAssertFalse(taskCell.waitForExistence(timeout: 2))
        
        taskCell = app.staticTexts["Task2"]
        XCTAssertTrue(taskCell.waitForExistence(timeout: 2))
        
        taskCell.swipeLeft()
        XCTAssertTrue(button.waitForExistence(timeout: 2))
        button.tap()
        
        XCTAssertFalse(taskCell.waitForExistence(timeout: 2))
    }
    
    func testSearchBarExists() throws {
        sleep(3)

        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
    }
    
    func testSearchFunctionality() throws {
        
        addRecurringTask()
        
        let allRecurringTasks = app.otherElements["RecurringTaskTab"]
        let addButton = allRecurringTasks.buttons["AddRecurringTaskButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 2))
        addButton.tap()
        
        let titleField = app.textFields.element(boundBy: 0)
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("Task Zwei")

        let saveButton = app.buttons["TaskFormSaveButton"]
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()
        
        sleep(3)

        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
        
        searchField.tap()

        searchField.typeText("Title")
        
        let taskCellFound = app.staticTexts["Task Title"]
        XCTAssertTrue(taskCellFound.waitForExistence(timeout: 2))
        
        let taskCellNotFound = app.staticTexts["Task Zwei"]
        XCTAssertFalse(taskCellNotFound.waitForExistence(timeout: 2))
        
        sleep(2)
        
        searchField.clearAndEnterText("")

        sleep(2)
        
        XCTAssertTrue(taskCellFound.waitForExistence(timeout: 2))
        XCTAssertTrue(taskCellNotFound.waitForExistence(timeout: 2))
        
        var start = taskCellFound.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5))
        var end = taskCellFound.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.5))
        start.press(forDuration: 0.1, thenDragTo: end)
        
        start = taskCellNotFound.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5))
        end = taskCellNotFound.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.5))
        start.press(forDuration: 0.1, thenDragTo: end)
        
    }

}
