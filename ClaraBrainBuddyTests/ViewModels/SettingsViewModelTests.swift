//
//  MockAppSettings.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 06.08.25.
//


import XCTest
@testable import ClaraBrainBuddy

// Mock AppSettings and SettingsManager
struct MockAppSettings: Equatable {
    var someSetting: Bool
}

class MockSettingsManager: SettingsManager {
    
    var mockSettings: AppSettings = {
        // Compute morning date
        let morningComponents = DateComponents(hour: 8, minute: 0)
        let morningDate = Calendar.current.date(from: morningComponents) ?? Date()
        
        // Compute evening date
        let eveningComponents = DateComponents(hour: 20, minute: 0)
        let eveningDate = Calendar.current.date(from: eveningComponents) ?? Date()
        
        // Return AppSettings instance
        return AppSettings(
            maxTodosForToday: 5,
            defaultEstimatedTimeForRecurringTasks: 30,
            defaultTimeForEnergyLevelCalculation: 10,
            daysAddedForDefaultDueDate: 3,
            showEmojis: true,
            showDueDateInSchedule: true,
            showResistanceInTodayView: false,
            showResistanceInAllTodosView: true,
            morningNotification: morningDate,
            eveningNotification: eveningDate
        )
    }()
    
    var didSaveSettings = false
    var savedSettings: AppSettings?
    
    override func loadSetings() -> AppSettings {
        return mockSettings
    }
    
    override func saveSettings(_ settings: AppSettings) {
        didSaveSettings = true
        savedSettings = settings
    }
}

final class SettingsViewModelTests: XCTestCase {
    
    func testLoadSettingsOnInitLoadsSettingsFromManager() {
        let mockManager = MockSettingsManager()
        let viewModel = SettingsViewModel(settingsManager: mockManager)
        
        XCTAssertEqual(viewModel.settings, mockManager.mockSettings)
    }
    
    func testSaveSettingsCallsManagerSaveWithCurrentSettings() {
        let mockManager = MockSettingsManager()
        let viewModel = SettingsViewModel(settingsManager: mockManager)
        
        // Change a setting
        viewModel.settings.maxTodosForToday=10
        viewModel.settings.defaultEstimatedTimeForRecurringTasks=15
        viewModel.settings.defaultTimeForEnergyLevelCalculation=16
        viewModel.settings.daysAddedForDefaultDueDate=5
        viewModel.settings.showEmojis=false
        viewModel.settings.showDueDateInSchedule=false
        
        XCTAssertFalse(mockManager.didSaveSettings)
        
        viewModel.saveSettings()
        
        XCTAssertTrue(mockManager.didSaveSettings)
        XCTAssertEqual(mockManager.savedSettings?.maxTodosForToday, 10)
        XCTAssertEqual(mockManager.savedSettings?.defaultEstimatedTimeForRecurringTasks, 15)
        XCTAssertEqual(mockManager.savedSettings?.defaultTimeForEnergyLevelCalculation, 16)
        XCTAssertEqual(mockManager.savedSettings?.daysAddedForDefaultDueDate, 5)
        XCTAssertEqual(mockManager.savedSettings?.showEmojis, false)
        XCTAssertEqual(mockManager.savedSettings?.showDueDateInSchedule, false)
        
        
    }
}
