//
//  ViewModels/SettingsViewModel.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 03.05.25.
//

import Foundation

class SettingsViewModel: ObservableObject {
    
    static let shared = SettingsViewModel()
    
    private let settingsManager : SettingsManager
    
    @Published var settings: AppSettings

    init(settingsManager: SettingsManager = SettingsManager()) {
        self.settingsManager = settingsManager
        self.settings = settingsManager.loadSetings()
    }

    func saveSettings() {
        settingsManager.saveSettings(settings)
    }
}
