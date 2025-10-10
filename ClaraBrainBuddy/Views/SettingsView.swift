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
    
    @State private var showTimeValidationAlert = false
    
    @State private var notificationsGranted: Bool = false
    
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
                
                if !notificationsGranted {
                    Section(header: Text(Localization.labels.dailyReminders)) {
                        Text(Localization.messages.enableNotifications)
                            .font(Font.app.tiny)
                            .foregroundColor(Color.theme.red)
                        
                        Button(action: {
                            NotificationManager.shared.openAppSettings()
                        }) {
                            Text("Open App Settings")
                                .font(Font.app.tiny)
                        }
                    }
                } else {
                    Section(header: Text(Localization.labels.dailyReminders)) {
                        DatePicker(Localization.labels.morningReminder,
                                   selection: $settingsViewModel.settings.morningNotification,
                                   displayedComponents: .hourAndMinute)
                        .disabled(!notificationsGranted)
                        .accessibilityIdentifier("MorningReminderPicker")
                    }
                    
                    Section() {
                        DatePicker(Localization.labels.eveningReminder,
                                   selection: $settingsViewModel.settings.eveningNotification,
                                   displayedComponents: .hourAndMinute)
                        .disabled(!notificationsGranted)
                        .accessibilityIdentifier("EveningReminderPicker")
                    }
                }
                
                
                Section(header: Text(Localization.labels.displayOptions)) {
                    Toggle(Localization.labels.showEmojis, isOn: $settingsViewModel.settings.showEmojis)
                        .accessibilityIdentifier("ShowEmojisToggle")
                }
                
                Section() {
                    Toggle(Localization.labels.showDueDate, isOn: $settingsViewModel.settings.showDueDateInSchedule)
                        .accessibilityIdentifier("ShowDueDateInListToggle")
                }
                

                Button(action: {
                    if !isMorningBeforeEvening() {
                        showTimeValidationAlert = true
                        return
                    }
                    settingsViewModel.saveSettings()
                    NotificationManager.shared.requestAuthorization { granted in
                        if granted {
                            NotificationManager.shared.rescheduleDailyNotifications(
                                morning: settingsViewModel.settings.morningNotification,
                                evening: settingsViewModel.settings.eveningNotification
                            )
                        } else {
                            print("Notifications not granted.")
                        }
                    }
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
            .alert(isPresented: $showTimeValidationAlert) {
                Alert(
                    title: Text(Localization.errors.invalidTimeSelectionTitle),
                    message: Text(Localization.errors.invalidTimeSelectionMessage),
                    dismissButton: .default(Text(Localization.labels.ok))
                )
            }
        }
        .onAppear {
            checkNotificationPermission()
        }
    }

    
    private func isMorningBeforeEvening() -> Bool {
        let calendar = Calendar.current
        let morningComponents = calendar.dateComponents([.hour, .minute], from: settingsViewModel.settings.morningNotification)
        let eveningComponents = calendar.dateComponents([.hour, .minute], from: settingsViewModel.settings.eveningNotification)
        guard
            let morningDate = calendar.date(from: morningComponents),
            let eveningDate = calendar.date(from: eveningComponents)
        else {
            return true
        }

        return morningDate < eveningDate
    }
    
    private func checkNotificationPermission() {
        
        if CommandLine.arguments.contains("UITestMode") {
            notificationsGranted = true
            return
        }
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationsGranted = settings.authorizationStatus == .authorized
            }
        }
    }
}
