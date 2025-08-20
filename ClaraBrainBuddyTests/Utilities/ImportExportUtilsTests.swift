//
//  ImportExportUtilsTests.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 06.08.25.
//


import XCTest
import CoreData
@testable import ClaraBrainBuddy

final class ImportExportUtilsTests: XCTestCase {
    
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        context = DataManager.shared.context
    }
    
    override func tearDown() {
        context = nil
        super.tearDown()
    }

    // MARK: - Test: Export & Import round trip
    func testExportAndImportTodos() {
        // Create sample Todos
        let date1 = makeDate("2025-08-01")
        let date2 = makeDate("2025-08-05")
        
        let todos: [Todo] = [
            createTodo(title: "Buy groceries", details: "Milk, Bread, Eggs", dueDate: date1, estimatedTime: 30, selectedForToday: true, isDone: false, resistance: 3),
            createTodo(title: "Workout", dueDate: date2, estimatedTime: 60, selectedForToday: false, isDone: true, resistance: 2)
        ]

        let fileName = "TestTodos.json"
        
        // Export to JSON file
        let fileURL = ImportExportUtils.exportListOfTodosToJSONFile(todos: todos, fileName: fileName)
        
        XCTAssertFalse(fileURL.path.isEmpty, "Exported file path should not be empty")
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path), "File should exist at path")

        // Import back from JSON
        let importedTodos = ImportExportUtils.importTodosFromJSONFile(context: context, fileURL: fileURL)
        
        XCTAssertEqual(importedTodos.count, todos.count, "Imported todos count should match original")

        // Compare important properties
        for (original, imported) in zip(todos, importedTodos) {
            XCTAssertEqual(original.title, imported.title)
            XCTAssertEqual(original.details, imported.details)
            XCTAssertEqual(original.dueDate, imported.dueDate)
            XCTAssertEqual(original.estimatedTime, imported.estimatedTime)
            XCTAssertEqual(false, imported.selectedForToday)
            XCTAssertEqual(original.isDone, imported.isDone)
            XCTAssertEqual(original.resistance, imported.resistance)
        }
    }
    
    // MARK: - Test: Import with invalid path
    func testImportWithInvalidPathReturnsEmptyArray() {
        let invalidURL = URL(fileURLWithPath: "/non/existent/file.json")
        let todos = ImportExportUtils.importTodosFromJSONFile(context: context, fileURL: invalidURL)
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
    
    private func createTodo(
        id: UUID = UUID(),
        title: String,
        details: String? = nil,
        dueDate: Date = Date(),
        estimatedTime: Int64? = nil,
        selectedForToday: Bool = false,
        isDone: Bool = false,
        resistance: Int64 = 0,
        sortOrder: Int64 = 0
    ) -> Todo {
        let todo: Todo = Todo(context: context)
        todo.id = id
        todo.title = title
        todo.details = details
        todo.dueDate = dueDate
        todo.isDone = isDone
        todo.estimatedTime = estimatedTime
        todo.selectedForToday = selectedForToday
        todo.sortOrder = sortOrder
        todo.resistance = resistance
        todo.createdAt = Date()
        return todo
    }
}
