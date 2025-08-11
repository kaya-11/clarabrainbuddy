//
//  CalendarViewUITests.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 10.08.25.
//


import XCTest
@testable import ClaraBrainBuddy

final class CalendarViewUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments.append("UITestMode")
        app.launch()
    }
    
    func testCalendarViewDisplaysFakeEvent() {
        let menuButton = app.buttons["ClaraMenu"]
        XCTAssertTrue(menuButton.waitForExistence(timeout: 2), "Menü-Button nicht gefunden")
        menuButton.tap()
        
        let calenderViewButton = app.buttons["CalenderViewButton"]
        XCTAssertTrue(calenderViewButton.waitForExistence(timeout: 2))
        calenderViewButton.tap()
        
        XCTAssertTrue(app.staticTexts["Test1 Meeting"].exists)
    }
    
    func testCalendarViewDisplaysFakeEventAlreadyExistAsTodo() {
        
        let menuButton = app.buttons["ClaraMenu"]
        XCTAssertTrue(menuButton.waitForExistence(timeout: 2), "Menü-Button nicht gefunden")
        menuButton.tap()
        
        let calenderViewButton = app.buttons["CalenderViewButton"]
        XCTAssertTrue(calenderViewButton.waitForExistence(timeout: 2))
        calenderViewButton.tap()
        
        let eventCell = app.staticTexts["Test2 Meeting"]
        XCTAssertTrue(eventCell.waitForExistence(timeout: 2))
        
        eventCell.swipeRight()
        
        app.buttons["AddEventAsTodayTodoButton"].tap()
        
        sleep(2)
        
        let cancelButton = app.buttons["CancelTodaysEventsButton"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 2), "Menü-Button nicht gefunden")
        cancelButton.tap()

        sleep(2)
        
        app.launch()
        
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        let todoCell = app.staticTexts["Test2 Meeting"]
        XCTAssertTrue(todoCell.waitForExistence(timeout: 2))
        
        todoCell.swipeLeft()
        app.buttons["TodaysTodosDeleteTodo"].tap()
        
        XCTAssertFalse(todoCell.waitForExistence(timeout: 2))

        let todayTab = app.otherElements["TodayTab"]
        let addButton = todayTab.buttons["AddTodayTodoButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 2))
    }
}
