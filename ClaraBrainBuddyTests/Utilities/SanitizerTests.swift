//
//  Todo.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 04.08.25.
//


import XCTest
import CoreData
@testable import ClaraBrainBuddy

final class SanitizerTests: XCTestCase {
    
    func testSanitizeTodosWithValidTodoShouldCleanFields() {
        let original: TodoDto = createTodo(
            title: "   Clean this title   ",
            details: "   Some detailed description   ",
            estimatedTime: 200,
            selectedForToday: true,
            resistance: 5
        )
        
        let result = Sanitizer.sanitizeTodos([original])
        
        XCTAssertEqual(result.count, 1)
        let sanitized = result[0]
        XCTAssertEqual(sanitized.title, "Clean this title")
        XCTAssertEqual(sanitized.details, "Some detailed description")
        XCTAssertEqual(sanitized.estimatedTime, 200)
        XCTAssertEqual(sanitized.selectedForToday, false)
        XCTAssertEqual(sanitized.isDone, false)
        XCTAssertEqual(sanitized.resistance, 5)
        XCTAssertNotEqual(sanitized.id, original.id)
    }
    
    func testSanitizeTodosWithEmptyTitleShouldBeExcluded() {
        let todo: TodoDto = createTodo(
            title: "   ",
            details: "Details"
        )
        
        let result = Sanitizer.sanitizeTodos([todo])
        XCTAssertEqual(result.count, 0)
    }
    
    func testSanitizeTodosWithTooLongTitleAndDetailsShouldBeTruncated() {
        let longTitle = String(repeating: "a", count: 150)
        let longDetails = String(repeating: "b", count: 600)
        
        let todo = createTodo(
            title: longTitle,
            details: longDetails,
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
        let todo: TodoDto = createTodo(
            title: "Valid Title",
            isDone: true
        )
        
        let result = Sanitizer.sanitizeTodos([todo])
        XCTAssertEqual(result.count, 1)
        XCTAssertNil(result[0].details)
    }
    
    func testSanitizeTodosWithOutOfBoundsEstimatedTimeShouldClamp() {
        let todo: TodoDto = createTodo(
            title: "Test",
            estimatedTime: 2000,
            resistance: -5
        )
        
        let result = Sanitizer.sanitizeTodos([todo])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].estimatedTime, 1440)
        XCTAssertEqual(result[0].resistance, 0)
    }
}


private func createTodo(
    title: String,
    details: String = "",
    estimatedTime: Int64? = nil,
    dueDate: Date = Date(),
    selectedForToday: Bool = false,
    isDone: Bool = false,
    resistance: Int64 = 0
) -> TodoDto {
    let todo = TodoDto(
        title: title,
        details: details,
        dueDate: dueDate,
        estimatedTime: estimatedTime,
        selectedForToday: selectedForToday,
        isDone: isDone,
        resistance: resistance)
    return todo
}
