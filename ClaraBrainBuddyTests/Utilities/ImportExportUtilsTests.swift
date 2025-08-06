//
//  ImportExportUtilsTests.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 06.08.25.
//


import XCTest
@testable import ClaraBrainBuddy

final class ImportExportUtilsTests: XCTestCase {

    // MARK: - Test: Export & Import round trip
    func testExportAndImportTodos() {
        // Create sample Todos
        let date1 = makeDate("2025-08-01")
        let date2 = makeDate("2025-08-05")
        
        let todos: [Todo] = [
            Todo(title: "Buy groceries", details: "Milk, Bread, Eggs", dueDate: date1, estimatedTime: 30, isSelectedForToday: true, isDone: false, resistance: 3),
            Todo(title: "Workout", details: nil, dueDate: date2, estimatedTime: 60, isSelectedForToday: false, isDone: true, resistance: 2)
        ]

        let fileName = "TestTodos.json"
        
        // Export to JSON file
        let fileURL = ImportExportUtils.exportTodosToJSONFile(todos: todos, fileName: fileName)
        
        XCTAssertFalse(fileURL.path.isEmpty, "Exported file path should not be empty")
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path), "File should exist at path")

        // Import back from JSON
        let importedTodos = ImportExportUtils.importTodosFromJSONFile(fileURL: fileURL)
        
        XCTAssertEqual(importedTodos.count, todos.count, "Imported todos count should match original")

        // Compare important properties
        for (original, imported) in zip(todos, importedTodos) {
            XCTAssertEqual(original.title, imported.title)
            XCTAssertEqual(original.details, imported.details)
            XCTAssertEqual(original.dueDate, imported.dueDate)
            XCTAssertEqual(original.estimatedTime, imported.estimatedTime)
            XCTAssertEqual(false, imported.isSelectedForToday)
            XCTAssertEqual(original.isDone, imported.isDone)
            XCTAssertEqual(original.resistance, imported.resistance)
        }
    }
    
    // MARK: - Test: Import with invalid path
    func testImportWithInvalidPathReturnsEmptyArray() {
        let invalidURL = URL(fileURLWithPath: "/non/existent/file.json")
        let todos = ImportExportUtils.importTodosFromJSONFile(fileURL: invalidURL)
        XCTAssertEqual(todos.count, 0, "Should return empty array for non-existent file")
    }
    
    // MARK: - Helper
    private func makeDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: dateString)!
    }
}
