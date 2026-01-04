//
//  TodaysTodosListUITests.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 07.08.25.
//


import XCTest
import SwiftUI
@testable import ClaraBrainBuddy

final class TodaysTodosListUITests: XCTestCase {
    
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        
        app.otherElements["TodayTab"].tap()
    }

    func testTodayTodoFlow() {
        addTodo()
        removeFromTodaysTodo()
        markForToday()
        markAsDone()
        deleteTodoFlow()
    }
    
    func testBadgeWithZeroTodos() {
        let image = app.images["CompletedTodosBadgeCheckmarkCircle"]
        XCTAssertTrue(image.exists, "Das Fragezeichen Image (ungefüllt) sollte angezeigt werden, wenn count = 0")
    }
    
    func testBadgeWithOneDoneTodos() {
        addTodo()
        markAsDone()
        
        sleep(2)
        
        let imageFilled = app.buttons["CompletedTodosBadgeCheckmarkCircleFill"]
        XCTAssertTrue(imageFilled.exists, "Das Badge sollte angezeigt werden, wenn count = 0")
        
        imageFilled.press(forDuration: 1.0)
        
        let deleteButton = app.buttons["Alle erledigte Aufgaben löschen"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 2.0), "Der Infoview sollte angezeigt werden")

        let infoText = app.staticTexts["Explanation"]
        XCTAssertTrue(infoText.waitForExistence(timeout: 2), "Info-Text sollte existieren")

        let label = infoText.label
        XCTAssertTrue(label.contains("1 Aufgabe(n) erledigt"), "Sollte '1 Aufgabe(n) erledigt' enthalten")
        XCTAssertTrue(label.contains("Benötigte Zeit: 15m"), "Sollte 'Benötigt Zeit:' enthalten")

        let backButton = app.buttons["backButton"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 2.0))
        
        backButton.tap()
        
        imageFilled.press(forDuration: 1.0)
        
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 2.0), "Der Infoview sollte angezeigt werden")
        
        deleteButton.tap()
        
        let imageNotFilled = app.images["CompletedTodosBadgeCheckmarkCircle"]
        XCTAssertTrue(imageNotFilled.exists, "Das Fragezeichen Image (ungefüllt) sollte angezeigt werden, wenn count = 0")
    }
    
    func testTimeBudgetSlider() {
        addTodo()
        
        let timeBudget = app.staticTexts["Geschätzte Zeit: 15 min."]
        XCTAssertTrue(timeBudget.waitForExistence(timeout: 2.0))
        
        let timeBudgetSlider = app.sliders["timeBudgetSlider"]
        XCTAssertTrue(timeBudgetSlider.waitForExistence(timeout: 2))
        
        sleep(1)

        timeBudgetSlider.adjust(toNormalizedSliderPosition: 1.0)
        
        sleep(1)

        timeBudgetSlider.adjust(toNormalizedSliderPosition: 0.0)
        
        sleep(1)

        timeBudgetSlider.adjust(toNormalizedSliderPosition: 0.5)
        
        let infoButton = app.buttons["infoButton"]
        XCTAssertTrue(infoButton.exists, "Der Info-Button wurde nicht gefunden.")
        infoButton.tap()
        
        let infoViewTitle = app.staticTexts["Zeitbudget"]
        XCTAssertTrue(infoViewTitle.waitForExistence(timeout: 2), "Der InfoView wurde nicht angezeigt.")
        
        let backButton = app.buttons["backButton"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 2.0))
        backButton.tap()
        
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
        
        app.tabBars.buttons[UITestUtils.TabNames.all].tap()
        
        
        let todoCell = app.staticTexts["Test Today Todo"]
        XCTAssertTrue(todoCell.waitForExistence(timeout: 2))
        
        todoCell.swipeRight()
        app.buttons["MarkForToday"].tap()
        
        XCTAssertTrue(todoCell.waitForExistence(timeout: 2))
        
        app.tabBars.buttons[UITestUtils.TabNames.today].tap()
        
        let todayTab = app.otherElements["TodayTab"]
        XCTAssertTrue(todayTab.waitForExistence(timeout: 2))
        
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
