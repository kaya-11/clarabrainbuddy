//
//  ClaraBrainBuddyApp.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//

import SwiftUI
import UserNotifications

@main
struct ClaraBrainBuddyApp: App {
    let context = DataManager.shared.context
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, context)
                .onAppear {
                    NotificationManager.shared.requestAuthorization { granted in
                        if granted {
                            NotificationManager.shared.rescheduleDailyNotifications(
                                morning: SettingsViewModel.shared.settings.morningNotification,
                                evening: SettingsViewModel.shared.settings.eveningNotification
                            )
                        } else {
                            print("Notifications not granted")
                        }
                    }
                }
        }
    }
}
