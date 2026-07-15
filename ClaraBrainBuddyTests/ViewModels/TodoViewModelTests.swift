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
        let todo2: Todo = createTodo(title: "T2", estimatedTime: 10)
        todo2.resistance = 5
        let todo3: Todo = createTodo(title: "T3", estimatedTime: nil)
        let todo4: Todo = createTodo(title: "T4", estimatedTime: 5)
        todo4.isDone = true
        
        
        viewModel.addTodos([todo1, todo2, todo3, todo4])
        
        viewModel.selectForToday(todo1)
        viewModel.selectForToday(todo2)
        viewModel.selectForToday(todo3)
        viewModel.selectForToday(todo4)
        
        // todo1 estimatedTime = 10, todo2 with a penalty of 100%, todo3 uses default (15), todo4 is done so ignored
        let total = viewModel.getTotalEstimatedTime(defaultEstimatedTime: 15)

        XCTAssertEqual(total, 45)
    }

    func testCalculateCompletedTodaysTodos() {
        
        let todo1: Todo = createTodo(title: "T1", estimatedTime: 10)
        todo1.isDone = true
        let todo2: Todo = createTodo(title: "T2", estimatedTime: 10)
        todo2.isDone = true
        todo2.resistance = 5
        let todo3: Todo = createTodo(title: "T3", estimatedTime: nil)
        todo3.isDone = true
        let todo4: Todo = createTodo(title: "T4", estimatedTime: 5)
        
        
        viewModel.addTodos([todo1, todo2, todo3, todo4])
        
        viewModel.selectForToday(todo1)
        viewModel.selectForToday(todo2)
        viewModel.selectForToday(todo3)
        viewModel.selectForToday(todo4)
        
        // todo1 estimatedTime = 10, todo2 with a penalty of 100%, todo3 uses default (15), todo4 is done so ignored
        let (total, time) = viewModel.calculateCompletedTodaysTodos(defaultEstimatedTime: 15)

        XCTAssertEqual(total, 3)
        XCTAssertEqual(time, 45)
    }
    
    func testGetTotalTodaysTodosCountNotDone() {
        
        let todo1: Todo = createTodo(title: "T1", estimatedTime: 10)
        todo1.isDone = true
        let todo2: Todo = createTodo(title: "T2", estimatedTime: 10)
        
        
        viewModel.addTodos([todo1, todo2])
        
        viewModel.selectForToday(todo1)
        viewModel.selectForToday(todo2)
        
        let total = viewModel.getTotalTodaysTodosCountNotDone()
        
        XCTAssertEqual(total, 1)
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
        XCTAssertTrue(title.contains("Duplikat"))
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
    
    func testUpdateTodoWithFormData() {
        let todo: Todo = createTodo(title: "Original Title", details: "Details")
        viewModel.addTodos([todo])
        
        var dueDateUpdated = Date().addingTimeInterval(24*3600)
        var todoFormData = createTodoFormData(dueDate: dueDateUpdated, isDone: false)
        
        _ = viewModel.updateTodo(todo, form: todoFormData)
        
        XCTAssertEqual(1, viewModel.allTodos.count)
        XCTAssertEqual("Title Updated", viewModel.allTodos[0].title, )
        XCTAssertEqual("Details Updated", viewModel.allTodos[0].details,)
        XCTAssertEqual(dueDateUpdated, viewModel.allTodos[0].dueDate)
        XCTAssertEqual(42, viewModel.allTodos[0].estimatedTime)
        XCTAssertEqual(1, viewModel.allTodos[0].energyImpact)
        XCTAssertFalse(viewModel.allTodos[0].isDone)
        
        // Resistance is one more, cause dueDate was changed into future
        XCTAssertEqual(1, viewModel.allTodos[0].resistance)
        
        dueDateUpdated = Date().addingTimeInterval(-24*3600)
        todoFormData = createTodoFormData(dueDate: dueDateUpdated, isDone: false)
        _ = viewModel.updateTodo(todo, form: todoFormData)
        
        // No change for resistance, cause dueDare was changed into past before today
        XCTAssertEqual(1, viewModel.allTodos[0].resistance)
        
        dueDateUpdated = Date().addingTimeInterval(2*24*3600)
        todoFormData = createTodoFormData(dueDate: dueDateUpdated, isDone: false)
        _ = viewModel.updateTodo(todo, form: todoFormData)
        
        // Resistance is one more, cause dueDate was changed again into future
        XCTAssertEqual(2, viewModel.allTodos[0].resistance)
        
        dueDateUpdated = Date().addingTimeInterval(24*3600)
        todoFormData = createTodoFormData(dueDate: dueDateUpdated, isDone: false)
        _ = viewModel.updateTodo(todo, form: todoFormData)
        
        // Resistance is one more, cause dueDate was changed again into future
        XCTAssertEqual(1, viewModel.allTodos[0].resistance)
        
        dueDateUpdated = Date()
        todoFormData = createTodoFormData(dueDate: dueDateUpdated, isDone: false)
        _ = viewModel.updateTodo(todo, form: todoFormData)
        
        // Resistance is one more, cause dueDate was changed again into future
        XCTAssertEqual(0, viewModel.allTodos[0].resistance)
        
        dueDateUpdated = Date().addingTimeInterval(2*24*3600)
        todoFormData = createTodoFormData(dueDate: dueDateUpdated, isDone: false)
        var vibrate = viewModel.updateTodo(todo, form: todoFormData)
        
        // App should not vibrate, cause isDone is false
        XCTAssertFalse(vibrate)
        
        // Resistance is one more, cause dueDate was changed again into future
        XCTAssertEqual(1, viewModel.allTodos[0].resistance)
        
        dueDateUpdated = Date().addingTimeInterval(4*24*3600)
        todoFormData = createTodoFormData(dueDate: dueDateUpdated, isDone: true)
        
        vibrate = viewModel.updateTodo(todo, form: todoFormData)
        
        // App should  vibrate, cause isDone is false
        XCTAssertTrue(vibrate)
        
        // Resistance has not changed, cause dueDate was changed again into future, but isDone is true
        XCTAssertEqual(1, viewModel.allTodos[0].resistance)
        
        dueDateUpdated = Date()
        todoFormData = createTodoFormData(dueDate: dueDateUpdated, isDone: true)
        
        vibrate = viewModel.updateTodo(todo, form: todoFormData)
        
        // App should  vibrate, cause isDone war alreay true
        XCTAssertFalse(vibrate)
        
        // Resistance has not changed, cause dueDate was changed to today, but isDone is true
        XCTAssertEqual(1, viewModel.allTodos[0].resistance)
        
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
        let todo5: Todo = createTodo(title: "Todo4", estimatedTime: 0, sortOrder: 4)
        
        viewModel.addTodos([todo1, todo2, todo3, todo4, todo5])
        
        viewModel.selectForToday(todo1)
        viewModel.selectForToday(todo2)
        viewModel.selectForToday(todo3)
        viewModel.selectForToday(todo4)
        viewModel.selectForToday(todo5)

        viewModel.reorderTodayTodos(defaultEstimatedTime: 2)
        
        XCTAssertEqual(viewModel.todayTodos[0].todo, todo5)
        XCTAssertEqual(viewModel.todayTodos[1].todo, todo4)
        XCTAssertEqual(viewModel.todayTodos[2].todo, todo3)
        XCTAssertEqual(viewModel.todayTodos[3].todo, todo2)
        XCTAssertEqual(viewModel.todayTodos[4].todo, todo1)
    }
    
    func testReorderTodos() {
        let todo1: Todo = createTodoWithDueDateAndCreatedAt(title: "Todo2", dueDate: Date()+1, createdAt: Date()+1, sortOrder: 1)
        let todo2: Todo = createTodoWithDueDateAndCreatedAt(title: "Todo1", dueDate: Date()+1, sortOrder: 0)
        let todo3: Todo = createTodoWithDueDateAndCreatedAt(title: "Todo3", sortOrder: 2)
        
        viewModel.addTodos([todo1, todo2, todo3])
  
        XCTAssertEqual(viewModel.allTodos[0], todo1)
        XCTAssertEqual(viewModel.allTodos[1], todo2)
        XCTAssertEqual(viewModel.allTodos[2], todo3)
    
        viewModel.reorderTodos()
        
        XCTAssertEqual(viewModel.allTodos[0], todo3)
        XCTAssertEqual(viewModel.allTodos[1], todo1)
        XCTAssertEqual(viewModel.allTodos[2], todo2)
    }
    
    private func createTodoWithDueDateAndCreatedAt(
        title: String,
        dueDate: Date = Date(),
        createdAt: Date = Date(),
        sortOrder: Int64 = 0
    ) -> Todo {
        let todo = Todo(context: context)
        todo.title = title
        todo.dueDate = dueDate
        todo.isDone = false
        todo.estimatedTime = 10
        todo.selectedForToday = false
        todo.sortOrder = sortOrder
        todo.resistance = 0
        todo.createdAt = createdAt
        todo.updatedAt = nil
        return todo
    }
    
    
    func testDeleteCompletedTodos() {
        let todo1: Todo = createTodo(title: "Todo1", estimatedTime: 5, isDone: true, sortOrder: 0)
        let todo2: Todo = createTodo(title: "Todo2", estimatedTime: 10, sortOrder: 1)
         
        viewModel.selectForToday(todo1)
        viewModel.selectForToday(todo2)
        
        XCTAssertEqual(viewModel.todayTodos.count, 2)
        viewModel.deleteCompletedTodos()
        XCTAssertEqual(viewModel.todayTodos.count, 1)
    }
    
    func testReprioritizeTodos_RemovesImportantAndNothingTasksFromToday() {
        // Setup
        let todo1 = createTodo(title: "Nothing", sortOrder: 0)
        let todo2 = createTodo(title: "Important", sortOrder: 1)
        let todo3 = createTodo(title: "Test0", isDone: true, sortOrder: 2)
        let todo4 = createTodo(title: "Urgent", sortOrder: 3)
        let todo5 = createTodo(title: "UrgentAndImportant", sortOrder: 4)
        let todo6 = createTodo(title: "Test1", sortOrder: 5)
        let todo7 = createTodo(title: "Test2", sortOrder: 6)
        

        viewModel.addTodos([todo1, todo2, todo3, todo4, todo5, todo6, todo7])
        viewModel.selectForToday(todo1)
        viewModel.selectForToday(todo2)
        viewModel.selectForToday(todo3)
        viewModel.selectForToday(todo4)
        viewModel.selectForToday(todo5)

        XCTAssertEqual(viewModel.todayTodos.count, 5)

        // Action
        viewModel.reprioritizeTodos(
            importantAndUrgentTasks: [todo5],
            urgentTasks: [todo4],
            importantTasks: [todo2],
            nothingOfBothTasks: [todo1]
        )

        // Assert
        XCTAssertEqual(viewModel.todayTodos.count, 3)
        XCTAssertTrue(viewModel.todayTodos[0].todo == todo5 )
        XCTAssertTrue(viewModel.todayTodos[1].todo == todo4 )
        XCTAssertTrue(viewModel.todayTodos[2].todo == todo3 )
        XCTAssertFalse(viewModel.todayTodos.contains { $0.todo == todo1 })
        XCTAssertFalse(viewModel.todayTodos.contains { $0.todo == todo2 })
        
        XCTAssertEqual(viewModel.allTodos.count, 7)
        XCTAssertTrue(viewModel.allTodos[0] == todo5 )
        XCTAssertTrue(viewModel.allTodos[1] == todo4 )
        XCTAssertTrue(viewModel.allTodos[2] == todo2 )
        XCTAssertTrue(viewModel.allTodos[3] == todo1 )
        XCTAssertTrue(viewModel.allTodos[4] == todo3 )
        XCTAssertTrue(viewModel.allTodos[5] == todo6 )
        XCTAssertTrue(viewModel.allTodos[6] == todo7 )
        
        for (index, todo) in viewModel.allTodos.enumerated() {
            XCTAssertEqual(todo.sortOrder, Int64(index))
        }
        for (index, todayTodo) in viewModel.todayTodos.enumerated() {
            XCTAssertEqual(todayTodo.sortOrder, Int64(index))
        }
    }
    
    func testMoveTodoTopDown() {
        // Setup
        let todo1 = createTodo(title: "Test1", sortOrder: 0)
        let todo2 = createTodo(title: "Test2", sortOrder: 1)
        let todo3 = createTodo(title: "Test3", sortOrder: 2)
        let todo4 = createTodo(title: "Test4", sortOrder: 3)
        let todo5 = createTodo(title: "Test5", sortOrder: 4)
        

        viewModel.addTodos([todo1, todo2, todo3, todo4, todo5])

        XCTAssertEqual(viewModel.allTodos.count, 5)

        // Action
        viewModel.moveTodo(source: todo1, destination: todo5)

        // Assert
        XCTAssertEqual(viewModel.allTodos.count, 5)
        
        XCTAssertTrue(viewModel.allTodos[0] == todo2 )
        XCTAssertTrue(viewModel.allTodos[1] == todo3 )
        XCTAssertTrue(viewModel.allTodos[2] == todo4 )
        XCTAssertTrue(viewModel.allTodos[3] == todo1 )
        XCTAssertTrue(viewModel.allTodos[4] == todo5 )
        
        for (index, todo) in viewModel.allTodos.enumerated() {
            XCTAssertEqual(todo.sortOrder, Int64(index))
        }
    }
    
    
    func testMoveTodoBottomUp() {
        // Setup
        let todo1 = createTodo(title: "Test1", sortOrder: 0)
        let todo2 = createTodo(title: "Test2", sortOrder: 1)
        let todo3 = createTodo(title: "Test3", sortOrder: 2)
        let todo4 = createTodo(title: "Test4", sortOrder: 3)
        let todo5 = createTodo(title: "Test5", sortOrder: 4)
        

        viewModel.addTodos([todo1, todo2, todo3, todo4, todo5])

        XCTAssertEqual(viewModel.allTodos.count, 5)

        // Action
        viewModel.moveTodo(source: todo5, destination: todo2)

        // Assert
        XCTAssertEqual(viewModel.allTodos.count, 5)
        
        XCTAssertTrue(viewModel.allTodos[0] == todo1 )
        XCTAssertTrue(viewModel.allTodos[1] == todo5 )
        XCTAssertTrue(viewModel.allTodos[2] == todo2 )
        XCTAssertTrue(viewModel.allTodos[3] == todo3 )
        XCTAssertTrue(viewModel.allTodos[4] == todo4 )
        
        for (index, todo) in viewModel.allTodos.enumerated() {
            XCTAssertEqual(todo.sortOrder, Int64(index))
        }
    }
    
    func testMoveTodoToEnd() {
        // Setup
        let todo1 = createTodo(title: "Test1", sortOrder: 0)
        let todo2 = createTodo(title: "Test2", sortOrder: 1)
        let todo3 = createTodo(title: "Test3", sortOrder: 2)
        let todo4 = createTodo(title: "Test4", sortOrder: 3)
        let todo5 = createTodo(title: "Test5", sortOrder: 4)
        

        viewModel.addTodos([todo1, todo2, todo3, todo4, todo5])

        XCTAssertEqual(viewModel.allTodos.count, 5)

        // Action
        viewModel.moveTodo(source: todo1, destination: todo5, aftereDestination: true)

        // Assert
        XCTAssertEqual(viewModel.allTodos.count, 5)
        
        XCTAssertTrue(viewModel.allTodos[0] == todo2 )
        XCTAssertTrue(viewModel.allTodos[1] == todo3 )
        XCTAssertTrue(viewModel.allTodos[2] == todo4 )
        XCTAssertTrue(viewModel.allTodos[3] == todo5 )
        XCTAssertTrue(viewModel.allTodos[4] == todo1 )
        
        for (index, todo) in viewModel.allTodos.enumerated() {
            XCTAssertEqual(todo.sortOrder, Int64(index))
        }
    }
    
    func testMoveTodoBehindOneTodo() {
        // Setup
        let todo1 = createTodo(title: "Test1", sortOrder: 0)
        let todo2 = createTodo(title: "Test2", sortOrder: 1)
        let todo3 = createTodo(title: "Test3", sortOrder: 2)
        let todo4 = createTodo(title: "Test4", sortOrder: 3)
        let todo5 = createTodo(title: "Test5", sortOrder: 4)
        

        viewModel.addTodos([todo1, todo2, todo3, todo4, todo5])

        XCTAssertEqual(viewModel.allTodos.count, 5)

        // Action
        viewModel.moveTodo(source: todo2, destination: todo4, aftereDestination: true)

        // Assert
        XCTAssertEqual(viewModel.allTodos.count, 5)
        
        XCTAssertTrue(viewModel.allTodos[0] == todo1 )
        XCTAssertTrue(viewModel.allTodos[1] == todo3 )
        XCTAssertTrue(viewModel.allTodos[2] == todo4 )
        XCTAssertTrue(viewModel.allTodos[3] == todo2 )
        XCTAssertTrue(viewModel.allTodos[4] == todo5 )
        
        for (index, todo) in viewModel.allTodos.enumerated() {
            XCTAssertEqual(todo.sortOrder, Int64(index))
        }
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
    
    private func createTodoFormData(
        dueDate: Date = Date(),
        isDone: Bool = false
    ) -> TodoFormData {
        let todoFormData = TodoFormData(
            title: "Title Updated",
            details: "Details Updated",
            dueDate: dueDate,
            estimatedTime: 42,
            energyImpact: 1,
            isDone: isDone,
            category: nil)
        return todoFormData
    }
        
}
