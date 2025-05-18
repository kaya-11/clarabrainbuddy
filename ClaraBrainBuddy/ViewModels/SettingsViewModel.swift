//
//  ViewModels/SettingsViewModel.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 03.05.25.
//

import Foundation

class SettingsViewModel: ObservableObject {
    
    private let settingsManager = SettingsManager()
    
    @Published var settings: AppSettings

    init() {
        settings = settingsManager.loadSetings()
    }

    func saveSettings() {
        settingsManager.saveSettings(settings)
    }
}
