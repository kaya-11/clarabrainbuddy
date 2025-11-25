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
                .onOpenURL { url in
                    Task {
                        await ExternalImportManager.shared.handleFile(url: url)
                    }
                }
        }
    }
}

struct AppInfo {
    static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }

    static var versionAndBuild: String {
        "v\(version) (\(buildNumber))"
    }
}

