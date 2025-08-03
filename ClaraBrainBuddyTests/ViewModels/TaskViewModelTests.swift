//
//  TodoViewModelTests.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 02.08.25.
//


import XCTest
@testable import ClaraBrainBuddy

class MockTaskManager: RecurringTaskManager {
    var savedTasks: [RecurringTask] = []
    
    override func saveTasks(_ tasks: [RecurringTask]) {
        savedTasks = tasks
    }
    
    override func loadTasks() -> [RecurringTask] {
        return savedTasks
    }
}

final class TaskViewModelTests: XCTestCase {
    
    var viewModel: TaskViewModel!
    var mockManager: RecurringTaskManager!
    
    override func setUp() {
        super.setUp()
        mockManager = MockTaskManager()
        viewModel = TaskViewModel(taskManager: mockManager)
    }
    
    override func tearDown() {
        viewModel = nil
        mockManager = nil
        super.tearDown()
    }
    
    func testAddRecurringTask() {
        let recurringTask = RecurringTask(id: UUID(),
                                          title: "Test Task",
                                          details: "Details",
                                          estimatedTime: 20,
                                          recurrenceRule: RecurrenceRule.daily)
        viewModel.allRecurringTasks.append(recurringTask);
        
        XCTAssertEqual(viewModel.allRecurringTasks.count, 1)
        
        viewModel.addRecurringTask(title: "New Task", details: "...", estimatedTime: 10, recurrenceRule: RecurrenceRule.evenDays)
        
        XCTAssertEqual(viewModel.allRecurringTasks.count, 2)
        XCTAssertEqual(viewModel.allRecurringTasks[0].title, "New Task")
    }
    
    func testUpdateRecurringTask() {
        var recurringTask = RecurringTask(id: UUID(),
                                          title: "Test Task",
                                          details: "Details",
                                          estimatedTime: 20,
                                          recurrenceRule: RecurrenceRule.daily)
        viewModel.allRecurringTasks.append(recurringTask);
        
        XCTAssertEqual(viewModel.allRecurringTasks.count, 1)
        
        recurringTask.title = "Updated Task"
        
        XCTAssertEqual(viewModel.allRecurringTasks[0].title, "Test Task")
        
        viewModel.updateRecurringTask(recurringTask)
        
        XCTAssertEqual(viewModel.allRecurringTasks.count, 1)
        XCTAssertEqual(viewModel.allRecurringTasks[0].title, "Updated Task")
    }
    
    func testDelteRecurringTask() {
        let recurringTask = RecurringTask(id: UUID(),
                                          title: "Test Task",
                                          details: "Details",
                                          estimatedTime: 20,
                                          recurrenceRule: RecurrenceRule.daily)
        viewModel.allRecurringTasks.append(recurringTask);
        
        XCTAssertEqual(viewModel.allRecurringTasks.count, 1)
        
        viewModel.deleteRecurringTask(recurringTask)
        
        XCTAssertEqual(viewModel.allRecurringTasks.count, 0)
    }
    
    func testMoveRecurringTasks() {
        let recurringTask1 = RecurringTask(id: UUID(),
                                          title: "Task1",
                                          details: "Details1")
        let recurringTask2 = RecurringTask(id: UUID(),
                                          title: "Task2",
                                          details: "Details2")
        
        viewModel.allRecurringTasks.append(recurringTask1)
        viewModel.allRecurringTasks.append(recurringTask2)
        
        XCTAssertEqual(viewModel.allRecurringTasks.count, 2)
        XCTAssertEqual(viewModel.allRecurringTasks[0].title, "Task1")
        XCTAssertEqual(viewModel.allRecurringTasks[1].details, "Details2")
        
        let indexSet = IndexSet(integer: 1)
        viewModel.moveRecurringTask(from: indexSet, to: 0)

        XCTAssertEqual(viewModel.allRecurringTasks.count, 2)
        XCTAssertEqual(viewModel.allRecurringTasks[0].title, "Task2")
        XCTAssertEqual(viewModel.allRecurringTasks[1].details, "Details1")
    }
}
