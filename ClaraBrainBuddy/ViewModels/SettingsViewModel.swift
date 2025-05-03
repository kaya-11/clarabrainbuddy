//
//  ViewModels/SettingsViewModel.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 03.05.25.
//

import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var settings: AppSettings

    private let userDefaultsKey = "AppSettings"

    init() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedSettings = try? JSONDecoder().decode(AppSettings.self, from: data) {
            self.settings = decodedSettings
        } else {
            self.settings = AppSettings(maxTodosForToday: 10, defaultEstimatedTimeForRecurringTasks: 15, defaultTimeForEnergyLevelCalculation: 15, daysAddedForDefaultDueDate: 14)
        }
    }

    func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
}
