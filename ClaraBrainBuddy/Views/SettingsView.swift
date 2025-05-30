//
//  Views/SettingsView.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 27.04.25.
//

import SwiftUI
import Foundation

struct SettingsView: View {

    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var viewModel = SettingsViewModel()
    @ObservedObject var settingsViewModel: SettingsViewModel

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Max Todos for Today")) {
                    Stepper(value: $settingsViewModel.settings.maxTodosForToday, in: 1...100) {
                        Text("\(settingsViewModel.settings.maxTodosForToday)")
                            .foregroundColor(Color.theme.primary)
                    }
                }

                Section(header: Text("Default Estimated Time for Recurring Tasks (minutes)")) {
                    Stepper(value: $settingsViewModel.settings.defaultEstimatedTimeForRecurringTasks, in: 1...120) {
                        Text("\(settingsViewModel.settings.defaultEstimatedTimeForRecurringTasks)")
                            .foregroundColor(Color.theme.primary)
                    }
                }

                Section(header: Text("Default Time for Energy Level Calculation (minutes)")) {
                    Stepper(value: $settingsViewModel.settings.defaultTimeForEnergyLevelCalculation, in: 1...60) {
                        Text("\(settingsViewModel.settings.defaultTimeForEnergyLevelCalculation)")
                            .foregroundColor(Color.theme.primary)
                    }
                }

                Section(header: Text("Days Added for Default Due Date")) {
                    Stepper(value: $settingsViewModel.settings.daysAddedForDefaultDueDate, in: 1...30) {
                        Text("\(settingsViewModel.settings.daysAddedForDefaultDueDate)")
                            .foregroundColor(Color.theme.primary)
                    }
                }

                Button(action: {
                    settingsViewModel.saveSettings()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save")
                        .foregroundColor(Color.theme.primary)
                }
                .font(Font.app.button)
            }
            .backgroundStyle()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(Localization.labels.back)
                            .font(Font.app.button)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(Localization.labels.properties)
                        .foregroundColor(Color.theme.primary)
                        .font(Font.app.title)
                }
            }
        }
    }
}
