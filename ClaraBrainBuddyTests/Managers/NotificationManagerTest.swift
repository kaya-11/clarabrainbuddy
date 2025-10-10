//
//  MockTaskManager.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 04.08.25.
//


//
//  TodoViewModelTests.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 02.08.25.
//


import XCTest
@testable import ClaraBrainBuddy

final class NotificationManagerTest: XCTestCase {

    func testScheduling() {
        let mockCenter = MockNotificationCenter()
        let manager = NotificationManager(center: mockCenter)
        
        let date = Date()
        manager.scheduleDailyNotification(identifier: "test", time: date, title: "Hello", body: "Body")
        
        assert(mockCenter.addedRequests.count == 1)
        assert(mockCenter.addedRequests.first?.identifier == "test")
    }
    
    func testRescheduleDailyNotifications() {
        let mockCenter = MockNotificationCenter()
        let manager = NotificationManager(center: mockCenter)

        let morning = Date()
        let evening = Date().addingTimeInterval(3600) // +1 Stunde

        manager.rescheduleDailyNotifications(
            morning: morning,
            evening: evening,
            morningTitle: "Good Morning",
            morningBody: "Morning Body",
            eveningTitle: "Good Evening",
            eveningBody: "Evening Body"
        )

        // Prüfen, dass removePendingNotificationRequests aufgerufen wurde
        XCTAssertTrue(mockCenter.removedIdentifiers.contains("morningNotification"))
        XCTAssertTrue(mockCenter.removedIdentifiers.contains("eveningNotification"))

        // Prüfen, dass neue Notifications hinzugefügt wurden
        let identifiers = mockCenter.addedRequests.map { $0.identifier }
        XCTAssertTrue(identifiers.contains("morningNotification"))
        XCTAssertTrue(identifiers.contains("eveningNotification"))

        // Optional: Titel prüfen
        let morningContent = mockCenter.addedRequests.first { $0.identifier == "morningNotification" }?.content
        XCTAssertEqual(morningContent?.title, "Good Morning")
        XCTAssertEqual(morningContent?.body, "Morning Body")
        let eveningContent = mockCenter.addedRequests.first { $0.identifier == "eveningNotification" }?.content
        XCTAssertEqual(eveningContent?.title, "Good Evening")
        XCTAssertEqual(eveningContent?.body, "Evening Body")
    }


}
