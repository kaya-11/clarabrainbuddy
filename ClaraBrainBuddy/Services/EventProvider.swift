//
//  Services/EventProvider.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 10.08.25.
//

import SwiftUI
import EventKit

protocol EventProvider {
    func fetchTodayEvents(completion: @escaping ([EKEvent]) -> Void)
    func fetchTodayAndTomorrowsEvents(completion: @escaping ([EKEvent]) -> Void)
}

class RealEventProvider: EventProvider {
    
    private func fetchEvents(from startDate: Date, to endDate: Date, completion: @escaping ([EKEvent]) -> Void) {
        let eventStore = EKEventStore()
        eventStore.requestFullAccessToEvents { granted, error in
            guard granted else {
                completion([])
                return
            }

            let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
            let events = eventStore.events(matching: predicate)
            completion(events)
        }
    }
    
    func fetchTodayEvents(completion: @escaping ([EKEvent]) -> Void) {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        fetchEvents(from: startDate, to: endDate, completion: completion)
    }

    func fetchTodayAndTomorrowsEvents(completion: @escaping ([EKEvent]) -> Void) {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        let endDate = calendar.date(byAdding: .day, value: 2, to: startDate)!
        fetchEvents(from: startDate, to: endDate, completion: completion)
    }
}

class FakeEventProvider: EventProvider {
    private func fetchEvents(completion: @escaping ([EKEvent]) -> Void) {
        let eventStore = EKEventStore()
        let calendar = Calendar.current
        let today = Date()

        // Event 1: Today at 11:30 - 12:00
        var startComponents1 = calendar.dateComponents([.year, .month, .day], from: today)
        startComponents1.hour = 11
        startComponents1.minute = 30
        let startDate1 = calendar.date(from: startComponents1)!

        var endComponents1 = startComponents1
        endComponents1.hour = 12
        endComponents1.minute = 0
        let endDate1 = calendar.date(from: endComponents1)!

        let event1 = EKEvent(eventStore: eventStore)
        event1.title = "Test1 Meeting"
        event1.startDate = startDate1
        event1.endDate = endDate1

        // Event 2: Today at 19:10 - 20:10
        var startComponents2 = calendar.dateComponents([.year, .month, .day], from: today)
        startComponents2.hour = 19
        startComponents2.minute = 10
        let startDate2 = calendar.date(from: startComponents2)!

        var endComponents2 = startComponents2
        endComponents2.hour = 20
        endComponents2.minute = 10
        let endDate2 = calendar.date(from: endComponents2)!

        let event2 = EKEvent(eventStore: eventStore)
        event2.title = "Test2 Meeting"
        event2.startDate = startDate2
        event2.endDate = endDate2

        completion([event1, event2])
    }
    
    func fetchTodayEvents(completion: @escaping ([EKEvent]) -> Void) {
        fetchEvents(completion: completion)
    }
    
    func fetchTodayAndTomorrowsEvents(completion: @escaping ([EKEvent]) -> Void) {
        fetchEvents(completion: completion)
    }
}
