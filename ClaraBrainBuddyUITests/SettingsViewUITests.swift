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
        app.launchArguments.append("UITestMode")
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
        
        // Scrollen bis der Button sichtbar ist
        while !saveButton.isHittable {
            app.swipeUp()
        }
        
        XCTAssertTrue(saveButton.exists)
        saveButton.tap()

        XCTAssertTrue(menuButton.waitForExistence(timeout: 2))
    }
    
    func testTogglesCanBeToggled() {
        let menuButton = app.buttons["ClaraMenu"]
        XCTAssertTrue(menuButton.waitForExistence(timeout: 2), "Menü-Button nicht gefunden")
        menuButton.tap()
        
        let settingsButton = app.buttons["SettingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 2))
        settingsButton.tap()

        // --- Test Show Symbols Toggle ---
        let showSymbolsToggle = app.switches["ShowSymbolsToggle"]
        XCTAssertTrue(showSymbolsToggle.waitForExistence(timeout: 2))
        
        let initialShowSymbolsValue = showSymbolsToggle.value as! String
        
        showSymbolsToggle.switches.firstMatch.tap()
        
        sleep(2)

        let toggledShowSymbolsValue = showSymbolsToggle.value as! String
        
        XCTAssertNotEqual(initialShowSymbolsValue, toggledShowSymbolsValue, "Toggling Show Symbols should change its value")
        
        // --- Test Show Due Date Toggle ---
        let showDueDateToggle = app.switches["ShowDueDateInListToggle"]
        while !showDueDateToggle.isHittable {
            app.swipeUp()
        }
        
        XCTAssertTrue(showDueDateToggle.exists, "Show Due Date toggle should exist")

        let initialShowDueDateValue = showDueDateToggle.value as? String
        
        showDueDateToggle.switches.firstMatch.tap()

        sleep(2)
        
        let toggledShowDueDateValue = showDueDateToggle.value as? String
        
        XCTAssertNotEqual(initialShowDueDateValue, toggledShowDueDateValue, "Toggling Show Due Date should change its value")
        
        // --- Test Show View Resistance Today Toggle ---
        let showResistanceInTodayViewToggle = app.switches["ShowResistanceInTodayViewToggle"]
        let showResistanceInAllTaskViewToggle = app.switches["ShowResistanceInAllTodosViewToggle"]
        
        while !showResistanceInAllTaskViewToggle.isHittable {
            app.swipeUp()
        }
        
        XCTAssertTrue(showResistanceInTodayViewToggle.exists, "Show resistance in today view toggle should exist")

        let initialShowResistanceInTodayViewValue = showResistanceInTodayViewToggle.value as? String
        
        showResistanceInTodayViewToggle.switches.firstMatch.tap()

        sleep(2)
        
        let toggledShowResistanceInTodayViewValue = showResistanceInTodayViewToggle.value as? String
        
        XCTAssertNotEqual(initialShowResistanceInTodayViewValue, toggledShowResistanceInTodayViewValue, "Toggling Show View Resistance in Today View should change its value")

        // --- Test Show View Resistance All Task Toggle ---
        
        XCTAssertTrue(showResistanceInAllTaskViewToggle.exists, "Show resistance in All task view toggle should exist")

        let initialShowResistanceInAllTaskViewValue = showResistanceInAllTaskViewToggle.value as? String
        
        showResistanceInAllTaskViewToggle.switches.firstMatch.tap()

        sleep(2)
        
        let toggledShowResistanceInAllTaskViewValue = showResistanceInAllTaskViewToggle.value as? String
        
        XCTAssertNotEqual(initialShowResistanceInAllTaskViewValue, toggledShowResistanceInAllTaskViewValue, "Toggling Show View Resistance in All Task View should change its value")

        
        // Scrollen bis der Button sichtbar ist (Hilfskontrukt)
        let saveButton = app.buttons["SaveSettingsButton"]
        while !saveButton.isHittable {
            app.swipeUp()
        }

        XCTAssertTrue(saveButton.exists)
        saveButton.tap()

        XCTAssertTrue(menuButton.waitForExistence(timeout: 2))
        
        // Reopen Settings
        menuButton.tap()
        
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 2))
        settingsButton.tap()
        
        // show symbols
        XCTAssertTrue(showSymbolsToggle.exists, "Show Symbols toggle should exist")

        let reopenedSettingsShowSymbolsValue = showSymbolsToggle.value as? String
        
        XCTAssertEqual(toggledShowSymbolsValue, reopenedSettingsShowSymbolsValue, "Toggle Show Due Date should have same Value after repoeniung Settings View")
        
        showSymbolsToggle.switches.firstMatch.tap()
        
        // show due date
        XCTAssertTrue(showDueDateToggle.exists, "Show Due Date toggle should exist")

        let reopenedSettingsShowDueDateValue = showDueDateToggle.value as? String
        
        XCTAssertEqual(toggledShowDueDateValue, reopenedSettingsShowDueDateValue, "Toggle Show Due Date should have same Value after repoeniung Settings View")
        
        showDueDateToggle.switches.firstMatch.tap()
        
        // show resistance in today view
        while !showResistanceInAllTaskViewToggle.isHittable {
            app.swipeUp()
        }
        
        let reopenedSettingsShowResistanceInTodayViewValue = showResistanceInTodayViewToggle.value as? String
        
        XCTAssertEqual(toggledShowResistanceInTodayViewValue, reopenedSettingsShowResistanceInTodayViewValue, "Toggle show resistance in today view should have same Value after repoeniung Settings View")
        
        showResistanceInTodayViewToggle.switches.firstMatch.tap()
        
        // show resistance in today view
        let reopenedSettingsShowResistanceInAllTaskViewValue = showResistanceInAllTaskViewToggle.value as? String
        
        XCTAssertEqual(toggledShowResistanceInAllTaskViewValue, reopenedSettingsShowResistanceInAllTaskViewValue, "Toggle show resistance in all task view should have same Value after repoeniung Settings View")
        
        showResistanceInAllTaskViewToggle.switches.firstMatch.tap()
        
        // Scrollen bis der Button sichtbar ist
        while !saveButton.isHittable {
            app.swipeUp()
        }
        
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
    
    func testNotificationDatePickersAndAlert() {
        
        let menuButton = app.buttons["ClaraMenu"]
        XCTAssertTrue(menuButton.waitForExistence(timeout: 2), "Menü-Button nicht gefunden")
        menuButton.tap()
        
        let settingsButton = app.buttons["SettingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 2))
        settingsButton.tap()
        
        let morningPicker = app.datePickers["MorningReminderPicker"]
        XCTAssertTrue(morningPicker.exists, "Morning DatePicker sollte sichtbar sein")
        
        let eveningPicker = app.datePickers["EveningReminderPicker"]
        XCTAssertTrue(eveningPicker.exists, "Evening DatePicker sollte sichtbar sein")
        
        // Hinweis - Erst einmal ohne Funktionstest der Datepicker - später

    }

}
