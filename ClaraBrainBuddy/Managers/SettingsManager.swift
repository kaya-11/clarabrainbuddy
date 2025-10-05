//
//  Managers/TodoManager.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//

import Foundation

class SettingsManager {
    
    private let userDefaultsKey = "AppSettings"

    func saveSettings(_ settings: AppSettings) {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    func loadSetings() -> AppSettings {
        var appSettings = AppSettings(
            maxTodosForToday: 10,
            defaultEstimatedTimeForRecurringTasks: 15,
            defaultTimeForEnergyLevelCalculation: 15,
            daysAddedForDefaultDueDate: 14,
            showEmojis: true,
            showDueDateInSchedule: true
        )
        
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedSettings = try? JSONDecoder().decode(AppSettings.self, from: data) {
            appSettings = decodedSettings
        } 
        return appSettings
    }
}
