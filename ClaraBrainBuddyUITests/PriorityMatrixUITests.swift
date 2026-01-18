//
//  PriorityMatrixUITests.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 07.12.25.
//
import XCTest
@testable import ClaraBrainBuddy

final class PriorityMatrixUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments.append("UITestMode")
        app.launch()
    }

    private func openPriorityMatrixView() {
        let menuButton = app.buttons["ClaraMenu"]
        XCTAssertTrue(menuButton.waitForExistence(timeout: 2), "Menü-Button nicht gefunden")
        menuButton.tap()
        
        let priorityMatrixButton = app.buttons["PriorityMatrixButton"]
        
        XCTAssertTrue(priorityMatrixButton.waitForExistence(timeout: 2), "PriorityMatrixButton sollte sichtbar sein")
        priorityMatrixButton.tap()
    }
    
    func testInfoButtonOpensSheet() {
        
        openPriorityMatrixView()
        
        let infoButton = app.buttons["infoButtonPriority"]
        XCTAssertTrue(infoButton.waitForExistence(timeout: 2))
        infoButton.tap()

        let infoSheetTitle = app.staticTexts["Zu viele Aufgaben in Deiner Tagesplanung?"]
        XCTAssertTrue(infoSheetTitle.waitForExistence(timeout: 2))

        app.buttons["Zurück"].tap()
        
        sleep(2)
        
        app.buttons["Abbrechen"].tap()
        
        sleep(2)
    }
    
    func testUsePriorityMatrix() {
        
        addTask(title: "Test1")
        addTask(title: "Test2")
        addTask(title: "Test3")
        addTask(title: "Test4")
        
        openPriorityMatrixView()
        
        dragTask(title: "Test1", matrix: "Weder noch")
        dragTask(title: "Test2", matrix: "Wichtig")
        dragTask(title: "Test3", matrix: "Dringend")
        dragTask(title: "Test4", matrix: "Dringend & Wichtig")
        
        let rearrangeButton = app.buttons["RearrangeButton"]
        XCTAssertTrue(rearrangeButton.waitForExistence(timeout: 2))
        rearrangeButton.tap()
        
        sleep(1)
        
        deleteTaskInAllTodosView(title: "Test1")
        deleteTaskInAllTodosView(title: "Test2")

        deleteTaskInTodayView(title: "Test3")
        deleteTaskInTodayView(title: "Test4")
    }
    
    func dragTask(title: String, matrix: String) {
        let priorityTodoContainer = app.collectionViews["PriorityTodoContainer"]
        let taskCell = priorityTodoContainer.cells.containing(.staticText, identifier: title).element(boundBy: 0)
        XCTAssertTrue(taskCell.waitForExistence(timeout: 2), "\(title) sollte in der PriorityMatrixView sichtbar sein")

        let nothingOfBothView = app.staticTexts[matrix]
        XCTAssertTrue(nothingOfBothView.waitForExistence(timeout: 2), "'\(matrix)' Box sollte sichtbar sein")
        
        let taskCellFrame = taskCell.frame
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0)).withOffset(CGVector(dx: taskCellFrame.midX, dy: taskCellFrame.midY))

        let end = nothingOfBothView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        start.press(forDuration: 0.5, thenDragTo: end)
        
        sleep(1)
    }
    
    func addTask(title: String) {
        
        let todayTab = app.otherElements["TodayTab"]
        let addButton = todayTab.buttons["AddTodayTodoButton"]
        addButton.tap()
        
        let titleField = app.textFields.element(boundBy: 0)
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText(title)

        // Save
        let saveButton = app.buttons["TodaysTodoFormSaveButton"]
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()

        // Form should dismiss, return to list
        XCTAssertTrue(addButton.waitForExistence(timeout: 2))
    }

    func deleteTaskInTodayView(title: String) {
        
        app.tabBars.buttons["Heute"].tap()
        
        let allTodosListContainer = app.collectionViews["TodaysListContainer"]
        XCTAssertTrue(allTodosListContainer.waitForExistence(timeout: 2), "TodaysListContainer sollte sichtbar sein")
        
        let todoCell = allTodosListContainer.cells.containing(.staticText, identifier: title).element(boundBy: 0)
        XCTAssertTrue(todoCell.waitForExistence(timeout: 2), "\(title)-Zelle sollte in der AllTodosView sichtbar sein")
        
        sleep(1)
        
        todoCell.swipeLeft()
        
        sleep(1)
        
        app.buttons["TodaysTodosDeleteTodo"].tap()
    }
    
    func deleteTaskInAllTodosView(title: String) {
        
        app.tabBars.buttons[UITestUtils.TabNames.all].tap()
    
        let allTodosListContainer = app.collectionViews["AllTodosListContainer"]
        XCTAssertTrue(allTodosListContainer.waitForExistence(timeout: 2), "AllTodosListContainer sollte sichtbar sein")
        
        let todoCell = allTodosListContainer.cells.containing(.staticText, identifier: title).element(boundBy: 0)
        XCTAssertTrue(todoCell.waitForExistence(timeout: 2), "\(title)-Zelle sollte in der AllTodosView sichtbar sein")
        
        sleep(1)
        
        todoCell.swipeLeft()
        
        sleep(1)
        
        app.buttons["TodoListDeleteTodo"].tap()
    }
}
