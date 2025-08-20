//
//  TodoViewModelTests.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 02.08.25.
//


import XCTest
import CoreData
@testable import ClaraBrainBuddy

final class TaskViewModelTests: XCTestCase {
    
    var viewModel: TaskViewModel!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        DataManager.resetForTests()
        context = DataManager.shared.context
        viewModel = TaskViewModel(context: context)
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testAddRecurringTask() {
        viewModel.addRecurringTask(title: "Test Task", details: "Details", estimatedTime: 10, recurrenceRule: RecurrenceRule.daily)
        
        do {
            try context.save()
        } catch {
            XCTFail("Saving context failed: \(error)")
        }
        
        XCTAssertEqual(viewModel.allRecurringTasks.count, 1)
        
        viewModel.addRecurringTask(title: "New Task", details: "...", estimatedTime: 10, recurrenceRule: RecurrenceRule.evenDays)
        
        XCTAssertEqual(viewModel.allRecurringTasks.count, 2)
        XCTAssertEqual(viewModel.allRecurringTasks[0].title, "Test Task")
        XCTAssertEqual(viewModel.allRecurringTasks[1].title, "New Task")
    }
    
    func testUpdateRecurringTask() {
        viewModel.addRecurringTask(title: "Test Task", details: "Details", estimatedTime: 20, recurrenceRule: RecurrenceRule.daily)
        
        let recurringTask: RecurringTask = viewModel.allRecurringTasks[0]
        
        XCTAssertEqual(viewModel.allRecurringTasks.count, 1)
        
        recurringTask.title = "Updated Task"
        
        viewModel.updateRecurringTask(recurringTask)
        
        XCTAssertEqual(viewModel.allRecurringTasks.count, 1)
        XCTAssertEqual(viewModel.allRecurringTasks[0].title, "Updated Task")
    }
    
    func testDelteRecurringTask() {
        viewModel.addRecurringTask(title: "Test Task", details: "Details", estimatedTime: 20, recurrenceRule: RecurrenceRule.daily)
        
        let recurringTask: RecurringTask = viewModel.allRecurringTasks[0]
        
        XCTAssertEqual(viewModel.allRecurringTasks.count, 1)
        
        viewModel.deleteRecurringTask(recurringTask)
        
        XCTAssertEqual(viewModel.allRecurringTasks.count, 0)
    }
    
    func testMoveRecurringTasks() {
        viewModel.addRecurringTask(title: "Task1", details: "Details1", estimatedTime: 20, recurrenceRule: RecurrenceRule.daily)
        viewModel.addRecurringTask(title: "Task2", details: "Details2", estimatedTime: 20, recurrenceRule: RecurrenceRule.daily)
        
        XCTAssertEqual(viewModel.allRecurringTasks.count, 2)
        XCTAssertEqual(viewModel.allRecurringTasks[0].title, "Task1")
        XCTAssertEqual(viewModel.allRecurringTasks[0].sortOrder, 0)
        XCTAssertEqual(viewModel.allRecurringTasks[1].details, "Details2")
        XCTAssertEqual(viewModel.allRecurringTasks[1].sortOrder, 1)
        
        let indexSet = IndexSet(integer: 1)
        viewModel.moveRecurringTask(from: indexSet, to: 0)

        XCTAssertEqual(viewModel.allRecurringTasks.count, 2)
        XCTAssertEqual(viewModel.allRecurringTasks[0].details, "Details2")
        XCTAssertEqual(viewModel.allRecurringTasks[1].title, "Task1")
    }
    
    private func createRecurringTask(
        id: UUID = UUID(),
        title: String,
        details: String = "",
        estimatedTime: Int64 = 0,
        recurrenceRuleAsString: String = RecurrenceRule.daily.encoded(),
        sortOrder: Int64 = 0
    ) -> RecurringTask {
        let task = RecurringTask(context: context)
        task.id = id
        task.title = title
        task.details = details
        task.estimatedTime = estimatedTime
        task.recurrenceRuleAsString = recurrenceRuleAsString
        task.sortOrder = sortOrder
        task.createdAt = Date()
        return task
    }
}
