//
//  TodoViewModelTests.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 02.08.25.
//


import XCTest
import EventKit
@testable import ClaraBrainBuddy

class MockTodoManager: TodoManager {
    var savedTodos: [Todo] = []
    var savedTodayTodos: [TodayTodo] = []
    var mostRecentTodo: Todo?

    override func saveTodos(_ todos: [Todo]) {
        savedTodos = todos
    }

    override func loadTodos() -> [Todo] {
        return savedTodos
    }

    override func saveTodayTodos(_ todayTodos: [TodayTodo]) {
        savedTodayTodos = todayTodos
    }

    override func loadTodayTodos() -> [TodayTodo] {
        return savedTodayTodos
    }

    override func saveMostRecentTodo(_ todo: Todo) {
        mostRecentTodo = todo
    }
}

final class TodoViewModelTests: XCTestCase {
    
    var viewModel: TodoViewModel!
    var mockManager: MockTodoManager!
    
    override func setUp() {
        super.setUp()
        mockManager = MockTodoManager()
        viewModel = TodoViewModel(todoManager: mockManager)
    }
    
    override func tearDown() {
        viewModel = nil
        mockManager = nil
        super.tearDown()
    }
    
    func testAddTodoAddsTodoAndSaves() {
        XCTAssertEqual(viewModel.allTodos.count, 0)
        
        viewModel.addTodo(title: "Test Todo", details: "Details", dueDate: nil, estimatedTime: 20)
        
        XCTAssertEqual(viewModel.allTodos.count, 1)
        XCTAssertEqual(viewModel.allTodos.first?.title, "Test Todo")
        XCTAssertEqual(mockManager.savedTodos.count, 1)
    }
    
    func testAddTodosInsertsMultipleTodos() {
        let todo1 = Todo(id: UUID(), title: "T1", details: "", dueDate: nil, estimatedTime: 10)
        let todo2 = Todo(id: UUID(), title: "T2", details: "", dueDate: nil, estimatedTime: 15)
        
        viewModel.addTodos([todo1, todo2])
        
        XCTAssertEqual(viewModel.allTodos.count, 2)
        XCTAssertEqual(viewModel.allTodos[0].title, "T1")
        XCTAssertEqual(viewModel.allTodos[1].title, "T2")
        XCTAssertEqual(mockManager.savedTodos.count, 2)
    }
    
    func testSelectForTodayFlagsTodoAndAddsToTodayTodos() {
        let todo = Todo(id: UUID(), title: "Test Select", details: "", dueDate: nil, estimatedTime: nil)
        viewModel.addTodos([todo])
        
        viewModel.selectForToday(todo)
        
        XCTAssertTrue(viewModel.allTodos.first!.isSelectedForToday)
        XCTAssertEqual(viewModel.todayTodos.count, 1)
        XCTAssertEqual(mockManager.savedTodayTodos.count, 1)
    }
    
    func testSelectForTodayTodoAlreadyIsSelectedForToday() {
        let todo = Todo(id: UUID(), title: "Test Select", details: "", dueDate: nil, estimatedTime: nil, isSelectedForToday: true)
        viewModel.addTodos([todo])
        let todayTodo = TodayTodo(todoId: todo.id)
        viewModel.todayTodos.append(todayTodo);
        
        viewModel.selectForToday(todo)
        
        XCTAssertTrue(viewModel.allTodos.first!.isSelectedForToday)
        XCTAssertEqual(viewModel.todayTodos.count, 1)
        XCTAssertEqual(mockManager.savedTodayTodos.count, 1)
    }
    
    func testSelectForTodayTodoNotInAllTodos() {
        let todo = Todo(id: UUID(), title: "Test Select", details: "", dueDate: nil, estimatedTime: nil, isSelectedForToday: true)
        
        viewModel.selectForToday(todo)
        
        XCTAssertEqual(viewModel.todayTodos.count, 0)
        XCTAssertEqual(mockManager.savedTodayTodos.count, 0)
    }
    
    func testAddRecurringTaskAsTodoForToday() {
        let recurringTask = RecurringTask(title: "Test Recurring Task")
        viewModel.addRecurringTaskAsTodoForToday(recurringTask)
        
        XCTAssertEqual(viewModel.todayTodos.count, 1)
        XCTAssertEqual(mockManager.savedTodayTodos.count, 1)
        
        XCTAssertTrue(viewModel.allTodos.first!.isSelectedForToday)
        XCTAssertEqual(viewModel.allTodos.first!.title, "Test Recurring Task")
    }
    
    
    func testEventAlreadyExistsAsTodoReturnsTrueIfExists() {
        let todoDate = Date()
        let todo = Todo(id: UUID(), title: "Event Title", details: "", dueDate: todoDate, estimatedTime: nil)
        viewModel.addTodos([todo])

        // Create EKEvent with same title and date
        let event = EKEvent(eventStore: EKEventStore())
        event.title = "Event Title"
        event.startDate = todoDate

        XCTAssertTrue(viewModel.eventAlreadyExistsAsTodo(event))
    }

    func testEventAlreadyExistsAsTodoReturnsFalseIfNotExists() {
        let todo = Todo(id: UUID(), title: "Other Title", details: "", dueDate: Date(), estimatedTime: nil)
        viewModel.addTodos([todo])

        let event = EKEvent(eventStore: EKEventStore())
        event.title = "Event Title"
        event.startDate = Date()

        XCTAssertFalse(viewModel.eventAlreadyExistsAsTodo(event))
    }

    func testDeselectForTodayUnflagsTodoAndRemovesFromTodayTodosAndIncreasesResistance() {
        var todo = Todo(id: UUID(), title: "Test Deselect", details: "", dueDate: nil, estimatedTime: nil)
        todo.isSelectedForToday = true

        viewModel.addTodos([todo])
        viewModel.selectForToday(todo)

        viewModel.deselectForToday(todo)

        XCTAssertFalse(viewModel.allTodos[0].isSelectedForToday)
        XCTAssertEqual(viewModel.allTodos[0].resistance, 1)
        XCTAssertEqual(viewModel.todayTodos.count, 0)
    }

    func testGetTotalEstimatedTimeCalculatesCorrectly() {
        let todo1 = Todo(id: UUID(), title: "T1", details: "", dueDate: nil, estimatedTime: 10, isDone: false)
        let todo2 = Todo(id: UUID(), title: "T2", details: "", dueDate: nil, estimatedTime: nil, isDone: false)
        let todo3 = Todo(id: UUID(), title: "T3", details: "", dueDate: nil, estimatedTime: 5, isDone: true)

        viewModel.addTodos([todo1, todo2, todo3])
        viewModel.todayTodos = [
            TodayTodo(id: UUID(), todoId: todo1.id),
            TodayTodo(id: UUID(), todoId: todo2.id),
            TodayTodo(id: UUID(), todoId: todo3.id)
        ]

        // todo1 estimatedTime = 10, todo2 uses default (15), todo3 is done so ignored
        let total = viewModel.getTotalEstimatedTime(defaultEstimatedTime: 15)

        XCTAssertEqual(total, 25)
    }

    func testMoveTodoOneDownSwapsAndIncreasesResistance() {
        let todo1 = Todo(id: UUID(), title: "T1", details: "", dueDate: nil, estimatedTime: nil, resistance: 0)
        let todo2 = Todo(id: UUID(), title: "T2", details: "", dueDate: nil, estimatedTime: nil, resistance: 0)
        viewModel.addTodos([todo1, todo2])

        viewModel.moveTodoOneDown(todo1)

        XCTAssertEqual(viewModel.allTodos[0].title, "T2")
        XCTAssertEqual(viewModel.allTodos[1].title, "T1")
        XCTAssertEqual(viewModel.allTodos[1].resistance, 1)
    }

    func testDeleteTodoRemovesTodoAndTodayTodo() {
        let todo = Todo(id: UUID(), title: "ToDelete", details: "", dueDate: nil, estimatedTime: nil)
        viewModel.addTodos([todo])
        viewModel.selectForToday(todo)

        viewModel.deleteTodo(todo)

        XCTAssertFalse(viewModel.allTodos.contains(todo))
        XCTAssertFalse(viewModel.todayTodos.contains(where: { $0.todoId == todo.id }))
        XCTAssertEqual(mockManager.savedTodos.count, 0)
        XCTAssertEqual(mockManager.savedTodayTodos.count, 0)
    }

    func testCloneTodoCreatesNewTodo() {
        let todo = Todo(id: UUID(), title: "Original", details: "Details", dueDate: nil, estimatedTime: nil)
        viewModel.addTodos([todo])

        viewModel.cloneTodo(todo: todo)

        XCTAssertEqual(viewModel.allTodos.count, 2)
        XCTAssertTrue(viewModel.allTodos[0].title.contains("Clone"))
        XCTAssertFalse(viewModel.allTodos[0].isDone)
    }
    
    func testUpdateTodo() {
        var todo = Todo(id: UUID(), title: "Original", details: "Details", dueDate: nil, estimatedTime: nil)
        viewModel.addTodos([todo])
        
        XCTAssertEqual(viewModel.allTodos.count, 1)
        XCTAssertEqual(viewModel.allTodos[0].title, "Original")
        XCTAssertEqual(viewModel.allTodos[0].details, "Details")
        XCTAssertEqual(viewModel.allTodos[0].dueDate, nil)
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
        let uuid1 = UUID()
        let uuid2 = UUID()
        let todo1 = Todo(id: uuid1, title: "Todo1", details: "...", dueDate: nil, estimatedTime: nil)
        let todo2 = Todo(id: uuid2, title: "Todo2", details: "...", dueDate: nil, estimatedTime: nil)
        
        viewModel.addTodos([todo1, todo2])
        
        XCTAssertEqual(viewModel.allTodos[0].id, uuid1)
        XCTAssertEqual(viewModel.allTodos[1].id, uuid2)
        
        viewModel.moveToTheTop(todo2)
        
        XCTAssertEqual(viewModel.allTodos[0].id, uuid2)
        XCTAssertEqual(viewModel.allTodos[1].id, uuid1)
    }
    
    func testMoveTodoToTheTopDoNothingIfTodoNotFound() {
        let uuid1 = UUID()
        let uuid2 = UUID()
        let todo1 = Todo(id: uuid1, title: "Todo1", details: "...", dueDate: nil, estimatedTime: nil)
        let todo2 = Todo(id: uuid2, title: "Todo2", details: "...", dueDate: nil, estimatedTime: nil)
        
        viewModel.addTodos([todo1])
        viewModel.moveToTheTop(todo2)
        
        XCTAssertFalse(todo2.isSelectedForToday)
        XCTAssertEqual(viewModel.allTodos.count, 1)
        XCTAssertEqual(viewModel.allTodos[0].id, uuid1)
    }
    
    func testSetToDone() {
        let todo = Todo(id: UUID(), title: "Todo1", details: "...", dueDate: nil, estimatedTime: nil)
        viewModel.addTodos([todo])
        XCTAssertFalse(todo.isDone)
        
        viewModel.setToDone(todo)
        
        let updatedTodo = viewModel.allTodos[0]
        XCTAssertTrue(updatedTodo.isDone)
    }
    
    func testMoveTodaysTodosToTheEnd() {
        let uuid1 = UUID()
        let uuid2 = UUID()
        let todayTodo1 = TodayTodo(todoId: uuid1)
        let todayTodo2 = TodayTodo(todoId: uuid2)
        
        viewModel.todayTodos = [todayTodo1, todayTodo2]
        
        XCTAssertEqual(viewModel.todayTodos.count, 2)
        XCTAssertEqual(viewModel.todayTodos[0].todoId, uuid1)
        XCTAssertEqual(viewModel.todayTodos[1].todoId, uuid2)
        
        let indexSet = IndexSet(integer: 1)
        viewModel.moveTodayTodos(from: indexSet, to: 0)
        
        XCTAssertEqual(viewModel.todayTodos.count, 2)
        XCTAssertEqual(viewModel.todayTodos[0].todoId, uuid2)
        XCTAssertEqual(viewModel.todayTodos[1].todoId, uuid1)
    }
    
    func testIsRecurringTaskInTodayTodos() {
        let recurringTask = RecurringTask(title: "Test Recurring Task")
        viewModel.addRecurringTaskAsTodoForToday(recurringTask)
        XCTAssertTrue(viewModel.isRecurringTaskInTodayTodos(recurringTask.id))
    }
    
    func testReorderTodaysTodos() {
        let uuid1 = UUID()
        let uuid2 = UUID()
        let uuid3 = UUID()
        let uuid4 = UUID()
        let todo1 = Todo(id: uuid1, title: "Todo1", details: "...", dueDate: nil, estimatedTime: 5, isDone: true)
        let todo2 = Todo(id: uuid2, title: "Todo2", details: "...", dueDate: nil, estimatedTime: 10)
        let todo3 = Todo(id: uuid3, title: "Todo3", details: "...", dueDate: nil, estimatedTime: 5)
        let todo4 = Todo(id: uuid4, title: "Todo4", details: "...", dueDate: nil, estimatedTime: nil)
        viewModel.allTodos = [todo1, todo2, todo3, todo4]
        
        let todayTodo1 = TodayTodo(todoId: uuid1)
        let todayTodo2 = TodayTodo(todoId: uuid2)
        let todayTodo3 = TodayTodo(todoId: uuid3)
        let todayTodo4 = TodayTodo(todoId: uuid4)
        viewModel.todayTodos = [todayTodo1, todayTodo2, todayTodo3, todayTodo4]
        
        viewModel.reorderTodayTodos()
        
        XCTAssertEqual(viewModel.todayTodos[0].todoId, uuid4)
        XCTAssertEqual(viewModel.todayTodos[1].todoId, uuid3)
        XCTAssertEqual(viewModel.todayTodos[2].todoId, uuid2)
        XCTAssertEqual(viewModel.todayTodos[3].todoId, uuid1)
    }
}
