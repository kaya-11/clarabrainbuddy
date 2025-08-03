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

final class DateUtilsTest: XCTestCase {

    func testGetDateThreeDaysFromNow() {
        let baseDate = ISO8601DateFormatter().date(from: "2025-08-01T00:00:00Z")!
        let expectedDate = ISO8601DateFormatter().date(from: "2025-08-04T00:00:00Z")!

        let result = DateUtils.getDateThreeDaysFrom(date: baseDate)
        XCTAssertEqual(Calendar.current.compare(result, to: expectedDate, toGranularity: .day), .orderedSame)
    }

    func testGetDateSevenDaysBeforeNow() {
        let baseDate = ISO8601DateFormatter().date(from: "2025-08-01T00:00:00Z")!
        let expectedDate = ISO8601DateFormatter().date(from: "2025-07-25T00:00:00Z")!

        let result = DateUtils.getDateSevenDaysBefore(date: baseDate)
        XCTAssertEqual(Calendar.current.compare(result, to: expectedDate, toGranularity: .day), .orderedSame)
    }
}
