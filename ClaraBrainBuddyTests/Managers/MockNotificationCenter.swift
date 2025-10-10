//
//  MockNotificationCenter.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 11.10.25.
//

@testable import ClaraBrainBuddy
import XCTest
import UserNotifications

class MockNotificationCenter: NotificationCenterProtocol {
    var addedRequests: [UNNotificationRequest] = []
    var removedIdentifiers: [String] = []
    
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?) {
        addedRequests.append(request)
        completionHandler?(nil)
    }
    
    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        removedIdentifiers.append(contentsOf: identifiers)
    }
    
    func removeAllPendingNotificationRequests() {
        removedIdentifiers.removeAll()
    }
    
    func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Void) {
        completionHandler(addedRequests)
    }
}
