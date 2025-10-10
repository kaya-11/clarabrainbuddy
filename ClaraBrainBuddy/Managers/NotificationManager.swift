//
//  Managers/NotificationManager.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 10.10.25.
//


import Foundation
import UserNotifications
import UIKit

protocol NotificationCenterProtocol {
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?)
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
    func removeAllPendingNotificationRequests()
    func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Void)
}

extension UNUserNotificationCenter: NotificationCenterProtocol {}

final class NotificationManager {
    static let shared = NotificationManager()

    private let center: NotificationCenterProtocol
    private let morningId = "morningNotification"
    private let eveningId = "eveningNotification"

    init(center: NotificationCenterProtocol = UNUserNotificationCenter.current()) {
        self.center = center
    }

    func requestAuthorization(completion: ((Bool) -> Void)? = nil) {
        (center as? UNUserNotificationCenter)?.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification auth error:", error)
            }
            completion?(granted)
        }
    }

    func scheduleDailyNotification(identifier: String, time: Date, title: String, body: String) {
        let calendar = Calendar.current
        var comps = calendar.dateComponents([.hour, .minute], from: time)
        comps.second = 0

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                print("Failed to schedule \(identifier):", error)
            } else {
                print("Scheduled \(identifier) at \(comps.hour ?? -1):\(String(format: "%02d", comps.minute ?? 0))")
            }
        }
    }

    func rescheduleDailyNotifications(
        morning: Date,
        evening: Date,
        morningTitle: String = Localization.messages.morningNotificationTitle,
        morningBody: String = Localization.messages.morningNotificationBody,
        eveningTitle: String = Localization.messages.eveningNotificationTitle,
        eveningBody: String = Localization.messages.eveningNotificationBody
    ) {
        center.removePendingNotificationRequests(withIdentifiers: [morningId, eveningId])

        scheduleDailyNotification(identifier: morningId, time: morning, title: morningTitle, body: morningBody)
        scheduleDailyNotification(identifier: eveningId, time: evening, title: eveningTitle, body: eveningBody)
    }

    func cancelMorning() { center.removePendingNotificationRequests(withIdentifiers: [morningId]) }
    func cancelEvening() { center.removePendingNotificationRequests(withIdentifiers: [eveningId]) }
    func cancelAll() { center.removeAllPendingNotificationRequests() }

    func listPendingRequests() {
        center.getPendingNotificationRequests { requests in
            for r in requests {
                print("Pending:", r.identifier, "->", r.content.title)
            }
        }
    }

    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        DispatchQueue.main.async { UIApplication.shared.open(url) }
    }
}
