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
    
    @ObservedObject var settingsViewModel: SettingsViewModel
    
    init(settingsViewModel: SettingsViewModel) {
        self.settingsViewModel = settingsViewModel
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(Localization.labels.maxTodosForToday)) {
                    Stepper(value: $settingsViewModel.settings.maxTodosForToday, in: 1...100) {
                        Text("\(settingsViewModel.settings.maxTodosForToday)")
                            .foregroundColor(Color.theme.primary)
                            .accessibilityIdentifier("MaxTodosStepperValue")
                    }
                    .accessibilityIdentifier("MaxTodosStepper")
                }

                Section(header: Text(Localization.labels.defaultEstimatedTime)) {
                    Stepper(value: $settingsViewModel.settings.defaultEstimatedTimeForRecurringTasks, in: 1...120) {
                        Text("\(settingsViewModel.settings.defaultEstimatedTimeForRecurringTasks)")
                            .foregroundColor(Color.theme.primary)
                            .accessibilityIdentifier("EstimatedTimeStepperValue")
                    }
                    .accessibilityIdentifier("EstimatedTimeStepper")
                }

                Section(header: Text(Localization.labels.defaultEnergyLevelCalculation)) {
                    Stepper(value: $settingsViewModel.settings.defaultTimeForEnergyLevelCalculation, in: 1...60) {
                        Text("\(settingsViewModel.settings.defaultTimeForEnergyLevelCalculation)")
                            .foregroundColor(Color.theme.primary)
                            .accessibilityIdentifier("EnergyCalcTimeStepperValue")
                    }
                    .accessibilityIdentifier("EnergyCalcTimeStepper")
                }

                Section(header: Text(Localization.labels.daysAddedForDueDate)) {
                    Stepper(value: $settingsViewModel.settings.daysAddedForDefaultDueDate, in: 1...90) {
                        Text("\(settingsViewModel.settings.daysAddedForDefaultDueDate)")
                            .foregroundColor(Color.theme.primary)
                            .accessibilityIdentifier("DueDateDaysStepperValue")
                    }
                    .accessibilityIdentifier("DueDateDaysStepper")
                }

                Button(action: {
                    settingsViewModel.saveSettings()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text(Localization.labels.save)
                        .foregroundColor(Color.theme.primary)
                }
                .font(Font.app.button)
                .accessibilityIdentifier("SaveSettingsButton")
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
                    .accessibilityIdentifier("SettingsBackButton")
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
