//
//  TodoViewModelTests.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 02.08.25.
//


import XCTest
import EventKit
import CoreData
@testable import ClaraBrainBuddy

final class TodoViewModelTests: XCTestCase {
    
    var viewModel: TodoViewModel!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        context = DataManager.shared.context
        viewModel = TodoViewModel(context: context)
        for (_, todo) in viewModel.allTodos.enumerated() {
            context.delete(todo)
        }
        for (_, todayTodo) in viewModel.todayTodos.enumerated() {
            context.delete(todayTodo)
        }
    }
    
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
        
    func testAddTodoAddsTodoAndSaves() {
        XCTAssertEqual(viewModel.allTodos.count, 0)
        
        viewModel.addTodo(title: "Test Todo", details: "Details", dueDate: Date(), estimatedTime: 20)
        
        XCTAssertEqual(viewModel.allTodos.count, 1)
        XCTAssertEqual(viewModel.allTodos[0].title, "Test Todo")
    }
    
    func testAddTodosInsertsMultipleTodos() {
        let todo1 = createTodo(title: "T1", estimatedTime: 10)
        let todo2 = createTodo(title: "T2", estimatedTime: 15)
        
        XCTAssertEqual(todo1.title, "T1")
        XCTAssertEqual(todo2.title, "T2")
        
        viewModel.addTodos([todo1, todo2])
        
        XCTAssertEqual(viewModel.allTodos.count, 2)
        
        XCTAssertEqual(viewModel.allTodos[0].title, "T1")
        XCTAssertEqual(viewModel.allTodos[1].title, "T2")
    }
    
    func testSelectForTodayFlagsTodoAndAddsToTodayTodos() {
        let todo = createTodo(title: "Test Select")
        viewModel.addTodos([todo])
        
        viewModel.selectForToday(todo)
        
        XCTAssertTrue(viewModel.allTodos.first!.selectedForToday)
        XCTAssertEqual(viewModel.todayTodos.count, 1)
    }
    
    func testSelectForTodayTodoAlreadyIsSelectedForToday() {
        let todo = createTodo(title: "Test Select", estimatedTime: nil, selectedForToday: true)
        viewModel.addTodos([todo])
    
        viewModel.selectForToday(todo)
        viewModel.selectForToday(todo)
        
        let todoFromViewModel = viewModel.allTodos[0]
        
        XCTAssertTrue(todoFromViewModel.selectedForToday)
        XCTAssertEqual(viewModel.allTodos.count, 1)
        XCTAssertEqual(viewModel.todayTodos.count, 1)
    }
    
    func testSelectForTodayTodoNotInAllTodos() {
        
        let todo: Todo = createTodo(title: "Test Select", estimatedTime: nil, selectedForToday: false)
        context.delete(todo)
        
        viewModel.selectForToday(todo)
        
        XCTAssertEqual(viewModel.todayTodos.count, 0)
    }
    
    func testAddRecurringTaskAsTodoForToday() {
        let recurringTask = RecurringTask(context: context)
        recurringTask.title = "Test Recurring Task"
        recurringTask.details = ""
        recurringTask.sortOrder = 0
        recurringTask.createdAt = Date()
        recurringTask.estimatedTime = 10
        
        viewModel.addRecurringTaskAsTodoForToday(recurringTask)
        
        XCTAssertEqual(viewModel.todayTodos.count, 1)
        
        let today: TodayTodo = viewModel.todayTodos[0]
        XCTAssertNotNil(today)
        let todo: Todo = today.todo
        XCTAssertNotNil(todo)
        
        XCTAssertTrue(todo.selectedForToday)
        XCTAssertEqual(todo.title, "Test Recurring Task")
    }
    
    
    func testEventAlreadyExistsAsTodoReturnsTrueIfExists() {
        let todoDate = Date()
        
        let todo = createTodo(title: "Event Title", dueDate: todoDate)
        
        viewModel.addTodos([todo])

        // Create EKEvent with same title and date
        let event = EKEvent(eventStore: EKEventStore())
        event.title = "Event Title"
        event.startDate = todoDate

        XCTAssertTrue(viewModel.eventAlreadyExistsAsTodo(event))
    }

    func testEventAlreadyExistsAsTodoReturnsFalseIfNotExists() {
        let todoDate = Date()
        
        let todo = createTodo(title: "Other Title", dueDate: todoDate)

        viewModel.addTodos([todo])

        let event = EKEvent(eventStore: EKEventStore())
        event.title = "Event Title"
        event.startDate = Date()

        XCTAssertFalse(viewModel.eventAlreadyExistsAsTodo(event))
    }

    func testDeselectForTodayUnflagsTodoAndRemovesFromTodayTodosAndIncreasesResistance() {
        
        let todo = createTodo(title: "Test Title")

        viewModel.addTodos([todo])
        
        viewModel.selectForToday(todo)

        viewModel.deselectForToday(todo)

        XCTAssertFalse(viewModel.allTodos[0].selectedForToday)
        XCTAssertEqual(viewModel.allTodos[0].resistance, 1)
        XCTAssertEqual(viewModel.todayTodos.count, 0)
    }

    func testGetTotalEstimatedTimeCalculatesCorrectly() {
        
        let todo1: Todo = createTodo(title: "T1", estimatedTime: 10)
        let todo2: Todo = createTodo(title: "T2", estimatedTime: nil)
        let todo3: Todo = createTodo(title: "T3", estimatedTime: 5)
        
        viewModel.addTodos([todo1, todo2, todo3])
        
        viewModel.selectForToday(todo1)
        viewModel.selectForToday(todo2)
        viewModel.selectForToday(todo3)
        
        // todo1 estimatedTime = 10, todo2 uses default (15), todo3 is done so ignored
        let total = viewModel.getTotalEstimatedTime(defaultEstimatedTime: 15)

        XCTAssertEqual(total, 30)
    }

    func testMoveTodoOneDownSwapsAndIncreasesResistance() {
        let todo1: Todo = createTodo(title: "T1", sortOrder: 0)
        let todo2: Todo = createTodo(title: "T2", sortOrder: 1)
        viewModel.addTodos([todo1, todo2])

        viewModel.moveTodoOneDown(todo1)

        XCTAssertEqual(viewModel.allTodos[0].title, "T2")
        XCTAssertEqual(viewModel.allTodos[1].title, "T1")
        XCTAssertEqual(viewModel.allTodos[1].resistance, 1)
    }

    func testDeleteTodoRemovesTodoAndTodayTodo() {
        let todo: Todo = createTodo(title: "ToDelete")
        viewModel.addTodos([todo])
        viewModel.selectForToday(todo)

        viewModel.deleteTodo(todo)

        XCTAssertFalse(viewModel.allTodos.contains(todo))
        XCTAssertFalse(viewModel.todayTodos.contains(where: { $0.todo == todo }))
    }

    func testCloneTodoCreatesNewTodo() {
        let todo: Todo = createTodo(title: "Original", details: "Details")
        viewModel.addTodos([todo])

        viewModel.cloneTodo(todo: todo)

        XCTAssertEqual(viewModel.allTodos.count, 2)
        let title = viewModel.allTodos[0].title
        XCTAssertTrue(title.contains("Clone"))
        let sortOrder = viewModel.allTodos[0].sortOrder
        XCTAssertEqual(sortOrder, 0)

    }
    
    func testUpdateTodo() {
        let todo: Todo = createTodo(title: "Original", details: "Details")
        viewModel.addTodos([todo])
        
        XCTAssertEqual(viewModel.allTodos.count, 1)
        XCTAssertEqual(viewModel.allTodos[0].title, "Original")
        XCTAssertEqual(viewModel.allTodos[0].details, "Details")
        XCTAssertNotNil(viewModel.allTodos[0].dueDate)
        XCTAssertEqual(viewModel.allTodos[0].estimatedTime, nil)
        XCTAssertFalse(viewModel.allTodos[0].isDone)
    
        todo.title = "Updated"
        todo.details = "Updated details"
        todo.estimatedTime = 100
        todo.isDone = true
        
        viewModel.updateTodo(todo)

        XCTAssertEqual(viewModel.allTodos.count, 1)
        XCTAssertEqual(viewModel.allTodos[0].title, "Updated")
        XCTAssertEqual(viewModel.allTodos[0].details, "Updated details")
        XCTAssertEqual(viewModel.allTodos[0].estimatedTime, 100)
        XCTAssertTrue(viewModel.allTodos[0].isDone)
    }
    
    func testMoveTodoToTheTop() {
        
        let todo1 = createTodo(title: "Todo1", details: "...", sortOrder: 0)
        let todo2 = createTodo(title: "Todo2", details: "...", sortOrder: 1)
        
        XCTAssertEqual(viewModel.allTodos[0], todo1)
        XCTAssertEqual(viewModel.allTodos[0].sortOrder, 0)
        XCTAssertEqual(viewModel.allTodos[1], todo2)
        XCTAssertEqual(viewModel.allTodos[1].sortOrder, 1)
        
        viewModel.moveToTheTop(todo2)
        
        XCTAssertEqual(viewModel.allTodos[0], todo2)
        XCTAssertEqual(viewModel.allTodos[1], todo1)
    }
    
    func testMoveTodoToTheTopDoNothingIfTodoNotFound() {
        let todo1: Todo = createTodo(title: "Todo1", details: "...", sortOrder: 0)
        viewModel.addTodos([todo1])
    
        let todo2: Todo = createTodo(title: "Todo2", details: "...", sortOrder: 1)
        context.delete(todo2)
        
        viewModel.moveToTheTop(todo2)
        
        XCTAssertEqual(viewModel.allTodos.count, 1)
        XCTAssertEqual(viewModel.allTodos[0], todo1)
    }
    
    func testSetToDone() {
        let todo: Todo = createTodo(title: "Todo", details: "...")
        
        viewModel.addTodos([todo])
        viewModel.selectForToday(todo)
        
        let todayTodo = viewModel.todayTodos[0]
        
        XCTAssertFalse(todo.isDone)
        
        viewModel.setToDone(todayTodo)
        
        let updatedTodo = viewModel.allTodos[0]
        XCTAssertTrue(updatedTodo.isDone)
    }
    
    func testMoveTodaysTodosToTheEnd() {
        let todo1: Todo = createTodo(title: "Todo1", details: "...", sortOrder: 0)
        let todo2: Todo = createTodo(title: "Todo2", details: "...", sortOrder: 1)
        
        viewModel.selectForToday(todo2)
        viewModel.selectForToday(todo1)
        
        XCTAssertEqual(viewModel.todayTodos.count, 2)
        XCTAssertEqual(viewModel.todayTodos[0].todo, todo1)
        XCTAssertEqual(viewModel.todayTodos[1].todo, todo2)
        
        let indexSet = IndexSet(integer: 1)
        viewModel.moveTodayTodos(from: indexSet, to: 0)
        
        XCTAssertEqual(viewModel.todayTodos.count, 2)
        XCTAssertEqual(viewModel.todayTodos[0].todo, todo2)
        XCTAssertEqual(viewModel.todayTodos[1].todo, todo1)
    }
    
    func testIsRecurringTaskInTodayTodos() {
        let recurringTask = RecurringTask(context: context)
        recurringTask.title = "Test Recurring Task"
        recurringTask.details = ""
        recurringTask.sortOrder = 0
        recurringTask.createdAt = Date()
        recurringTask.estimatedTime = 10
        viewModel.addRecurringTaskAsTodoForToday(recurringTask)
        XCTAssertTrue(viewModel.isRecurringTaskInTodayTodos(recurringTask))
    }
    
    func testReorderTodaysTodos() {
        let todo1: Todo = createTodo(title: "Todo1", estimatedTime: 5, isDone: true, sortOrder: 0)
        let todo2: Todo = createTodo(title: "Todo2", estimatedTime: 10, sortOrder: 1)
        let todo3: Todo = createTodo(title: "Todo3", estimatedTime: 5, sortOrder: 2)
        let todo4: Todo = createTodo(title: "Todo4", estimatedTime: nil, sortOrder: 3)
        
        viewModel.addTodos([todo1, todo2, todo3, todo4])
        
        viewModel.selectForToday(todo1)
        viewModel.selectForToday(todo2)
        viewModel.selectForToday(todo3)
        viewModel.selectForToday(todo4)

        viewModel.reorderTodayTodos()
        
        XCTAssertEqual(viewModel.todayTodos[0].todo, todo4)
        XCTAssertEqual(viewModel.todayTodos[1].todo, todo3)
        XCTAssertEqual(viewModel.todayTodos[2].todo, todo2)
        XCTAssertEqual(viewModel.todayTodos[3].todo, todo1)
    }
    
    private func createTodo(
        title: String,
        estimatedTime: Int64? = nil,
        details: String = "",
        dueDate: Date = Date(),
        selectedForToday: Bool = false,
        isDone: Bool = false,
        sortOrder: Int64 = 0
    ) -> Todo {
        let todo = Todo(context: context)
        todo.title = title
        todo.details = details
        todo.dueDate = dueDate
        todo.isDone = isDone
        todo.estimatedTime = estimatedTime
        todo.selectedForToday = selectedForToday
        todo.sortOrder = sortOrder
        todo.resistance = 0
        todo.createdAt = Date()
        todo.updatedAt = nil
        return todo
    }
    
}
