//
//  ContentViewUITest.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 06.08.25.
//

import XCTest

final class ContentViewUITest: XCTestCase {

    func testContentViewVisibilityAndTabSwitching() {
        let app = XCUIApplication()
        app.launch()

        // Wait 4 seconds (to allow the 3-sec delay to finish)
        sleep(4)
        
        // Verify tab exist
        let allTabs = app.tabBars.buttons[UITestUtils.TabNames.all]
        XCTAssertTrue(allTabs.exists, "All Tasks Tab should exist")
        allTabs.tap()

        // Today Tab is shown on start up
        let todayTab = app.tabBars.buttons[UITestUtils.TabNames.today]
        XCTAssertTrue(todayTab.exists, "TodayTab should exist")
        todayTab.tap()
        
        // switch to last tab
        let lastTab = app.tabBars.buttons[UITestUtils.TabNames.recurring]
        XCTAssertTrue(lastTab.exists, "Last Tab should exist.")
        lastTab.tap()
    }
    
    func testRandomTodoOverlayIsVisible() {
        let app = XCUIApplication()
        app.launchArguments.append("--UITestMode")
        app.launch()
        let noTodosText = app.staticTexts["NoTodosText"]

        let existsPredicate = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: existsPredicate, object: noTodosText)

        let result = XCTWaiter().wait(for: [expectation], timeout: 3)
        XCTAssertEqual(result, .completed, "Expected the 'no todos' message to appear.")
        XCTAssertTrue(noTodosText.exists)
        
        let disappearsPredicate = NSPredicate(format: "exists == false")
        let disappearsExpectation = XCTNSPredicateExpectation(predicate: disappearsPredicate, object: noTodosText)
        let disappearResult = XCTWaiter().wait(for: [disappearsExpectation], timeout: 6)
        
        XCTAssertEqual(disappearResult, .completed, "Expected RandomTodoView to disappear after delay.")

    }
    
    func testRandomTodoView() {
        let app = XCUIApplication()
        app.launchArguments.append("--UITestMode")
        app.launch()
        
        app.tabBars.buttons[UITestUtils.TabNames.all].tap()
        
        // Add Todo
        let allTodosTab = app.otherElements["AllTodosTab"]
        let addButton = allTodosTab.buttons["AddTodoButton"]
        addButton.tap()
        
        let titleField = app.textFields.element(boundBy: 0)
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("Random Todo")

        let saveButton = app.buttons["TodoFormSaveButton"]
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()
        
        // Check Random Todo
        app.terminate()
        sleep(2)
        app.launch()
        
        let randomTodosText = app.staticTexts["Random Todo"]
        let existsPredicate = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: existsPredicate, object: randomTodosText)

        let result = XCTWaiter().wait(for: [expectation], timeout: 2)
        XCTAssertEqual(result, .completed, "Expected the 'no todos' message to appear.")
        XCTAssertTrue(randomTodosText.exists)
        
        randomTodosText.swipeLeft()
    
        sleep(2)
        
        app.tabBars.buttons[UITestUtils.TabNames.all].tap()
        
        let todoCell = app.staticTexts["Random Todo"]
        XCTAssertFalse(todoCell.waitForExistence(timeout: 2))
    }
}
