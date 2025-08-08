//
//  SettingsViewUITests.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 07.08.25.
//


import XCTest

final class SettingsViewUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }


    func testSettingsStepperInteractions() {
        let menuButton = app.buttons["ClaraMenu"]
        XCTAssertTrue(menuButton.waitForExistence(timeout: 2), "Menü-Button nicht gefunden")
        menuButton.tap()
        
        let settingsButton = app.buttons["SettingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 2))
        settingsButton.tap()

        // MaxTodos Stepper
        let maxTododsStepper = app.steppers["MaxTodosStepper"]
        let maxTododsValueLabel = app.staticTexts["MaxTodosStepperValue"]

        XCTAssertTrue(maxTododsStepper.exists)
        XCTAssertTrue(maxTododsValueLabel.exists)

        let initialValue = Int(maxTododsValueLabel.label) ?? 0
        
        maxTododsStepper.buttons.element(boundBy: 1).tap()
        let incrementedValue = Int(maxTododsValueLabel.label) ?? 0
        XCTAssertEqual(incrementedValue, initialValue + 1)

        maxTododsStepper.buttons.element(boundBy: 0).tap()
        let decrementedValue = Int(maxTododsValueLabel.label) ?? 0
        XCTAssertEqual(decrementedValue, initialValue)
        
        // EstimatedTime Stepper
        let estimatedTimeStepper = app.steppers["EstimatedTimeStepper"]
        let estimatedTimeValueLabel = app.staticTexts["EstimatedTimeStepperValue"]

        XCTAssertTrue(estimatedTimeStepper.exists)
        XCTAssertTrue(estimatedTimeValueLabel.exists)

        let estimatedTimeInitial = Int(estimatedTimeValueLabel.label) ?? 0

        estimatedTimeStepper.buttons.element(boundBy: 1).tap()
        let estimatedTimeIncremented = Int(estimatedTimeValueLabel.label) ?? 0
        XCTAssertEqual(estimatedTimeIncremented, estimatedTimeInitial + 1)

        estimatedTimeStepper.buttons.element(boundBy: 0).tap()
        let estimatedTimeDecremented = Int(estimatedTimeValueLabel.label) ?? 0
        XCTAssertEqual(estimatedTimeDecremented, estimatedTimeInitial)

        // EnergyCalcTime Stepper
        let energyCalcStepper = app.steppers["EnergyCalcTimeStepper"]
        let energyCalcValueLabel = app.staticTexts["EnergyCalcTimeStepperValue"]

        XCTAssertTrue(energyCalcStepper.exists)
        XCTAssertTrue(energyCalcValueLabel.exists)

        let energyCalcInitial = Int(energyCalcValueLabel.label) ?? 0

        energyCalcStepper.buttons.element(boundBy: 1).tap()
        let energyCalcIncremented = Int(energyCalcValueLabel.label) ?? 0
        XCTAssertEqual(energyCalcIncremented, energyCalcInitial + 1)

        energyCalcStepper.buttons.element(boundBy: 0).tap()
        let energyCalcDecremented = Int(energyCalcValueLabel.label) ?? 0
        XCTAssertEqual(energyCalcDecremented, energyCalcInitial)

        // DueDateDays Stepper
        let dueDateStepper = app.steppers["DueDateDaysStepper"]
        let dueDateValueLabel = app.staticTexts["DueDateDaysStepperValue"]

        XCTAssertTrue(dueDateStepper.exists)
        XCTAssertTrue(dueDateValueLabel.exists)

        let dueDateInitial = Int(dueDateValueLabel.label) ?? 0

        dueDateStepper.buttons.element(boundBy: 1).tap()
        let dueDateIncremented = Int(dueDateValueLabel.label) ?? 0
        XCTAssertEqual(dueDateIncremented, dueDateInitial + 1)

        dueDateStepper.buttons.element(boundBy: 0).tap()
        let dueDateDecremented = Int(dueDateValueLabel.label) ?? 0
        XCTAssertEqual(dueDateDecremented, dueDateInitial)

        // Tap Save button
        let saveButton = app.buttons["SaveSettingsButton"]
        XCTAssertTrue(saveButton.exists)
        saveButton.tap()

        XCTAssertTrue(menuButton.waitForExistence(timeout: 2))
    }

    func testBackButtonDismissesSettings() {
        
        let menuButton = app.buttons["ClaraMenu"]
        XCTAssertTrue(menuButton.waitForExistence(timeout: 2), "Menü-Button nicht gefunden")
        menuButton.tap()
        
        let settingsButton = app.buttons["SettingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 2), "Menü-Button nicht gefunden")
        settingsButton.tap()

        let backButton = app.buttons["SettingsBackButton"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 2))
        backButton.tap()

        XCTAssertTrue(menuButton.waitForExistence(timeout: 2))
    }
}
