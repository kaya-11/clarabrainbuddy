//
//  Todo.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 04.08.25.
//


import XCTest
@testable import ClaraBrainBuddy

final class SanitizerTests: XCTestCase {
    
    func testSanitizeTodosWithValidTodoShouldCleanFields() {
        let original = Todo(
            id: UUID(),
            title: "   Clean this title   ",
            details: "   Some detailed description   ",
            dueDate: Date(),
            estimatedTime: 200,
            isSelectedForToday: true,
            isDone: false,
            resistance: 5
        )
        
        let result = Sanitizer.sanitizeTodos([original])
        
        XCTAssertEqual(result.count, 1)
        let sanitized = result[0]
        XCTAssertEqual(sanitized.title, "Clean this title")
        XCTAssertEqual(sanitized.details, "Some detailed description")
        XCTAssertEqual(sanitized.estimatedTime, 200)
        XCTAssertEqual(sanitized.isSelectedForToday, false)
        XCTAssertEqual(sanitized.isDone, false)
        XCTAssertEqual(sanitized.resistance, 5)
        XCTAssertNotEqual(sanitized.id, original.id)
    }
    
    func testSanitizeTodosWithEmptyTitleShouldBeExcluded() {
        let todo = Todo(
            id: UUID(),
            title: "   ",
            details: "Details",
            dueDate: nil,
            estimatedTime: nil,
            isSelectedForToday: false,
            isDone: false,
            resistance: nil
        )
        
        let result = Sanitizer.sanitizeTodos([todo])
        XCTAssertEqual(result.count, 0)
    }
    
    func testSanitizeTodosWithTooLongTitleAndDetailsShouldBeTruncated() {
        let longTitle = String(repeating: "a", count: 150)
        let longDetails = String(repeating: "b", count: 600)
        
        let todo = Todo(
            id: UUID(),
            title: longTitle,
            details: longDetails,
            dueDate: nil,
            estimatedTime: nil,
            isSelectedForToday: false,
            isDone: true,
            resistance: 11
        )
        
        let result = Sanitizer.sanitizeTodos([todo])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].title.count, 100)
        XCTAssertEqual(result[0].details?.count, 500)
        XCTAssertEqual(result[0].resistance, 10)
    }
    
    func testSanitizeTodosWithNilDetailsShouldRemainNil() {
        let todo = Todo(
            id: UUID(),
            title: "Valid Title",
            details: nil,
            dueDate: nil,
            estimatedTime: nil,
            isSelectedForToday: false,
            isDone: true,
            resistance: 0
        )
        
        let result = Sanitizer.sanitizeTodos([todo])
        XCTAssertEqual(result.count, 1)
        XCTAssertNil(result[0].details)
    }
    
    func testSanitizeTodosWithNildResistanceShouldDefaulted() {
        let todo = Todo(
            id: UUID(),
            title: "Valid Title",
            details: "...",
            dueDate: nil,
            estimatedTime: nil,
            isSelectedForToday: false,
            isDone: true,
            resistance: nil
        )
        
        let result = Sanitizer.sanitizeTodos([todo])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].resistance, 0)
    }
    
    func testSanitizeTodosWithOutOfBoundsEstimatedTimeShouldClamp() {
        let todo = Todo(
            id: UUID(),
            title: "Test",
            details: nil,
            dueDate: nil,
            estimatedTime: 2000,
            isSelectedForToday: false,
            isDone: false,
            resistance: -5
        )
        
        let result = Sanitizer.sanitizeTodos([todo])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].estimatedTime, 1440)
        XCTAssertEqual(result[0].resistance, 0)
    }
}
