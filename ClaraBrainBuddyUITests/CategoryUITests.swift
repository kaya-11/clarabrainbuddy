//
//  CategoryUITests.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 10.01.26.
//
import XCTest
import CoreData

@testable import ClaraBrainBuddy

class CategoryUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }
    
    func testCategoryAndTodoFlow() throws {
        addCategory()
        addTodo()
        deleteCategory(deletionOk: false)
        deleteTodo()
        deleteCategory()
    }

    func testCategoryAsDefaultAndTodoFlow() throws {
        addCategory()
        editCategory()
        addTodo(useDefault: true)
        deleteCategory(deletionOk: false)
        deleteTodo()
        deleteCategory()
    }
    
    func testCategoryAsDefaultAndTodayTodoFlow() throws {
        addCategory()
        editCategory()
        addTodayTodo(useDefault: true)
        deleteCategory(deletionOk: false)
        deleteTodo()
        deleteCategory()
    }
    
    func testCategoryOverview() throws {
        let cat1: String = "Arbeit"
        let cat2: String = "Privat"
        addCategory(categoryName: cat1)
        editCategory(categoryName: cat1)
        
        addCategory(categoryName: cat2)
        
        app.terminate()
        sleep(2)
        app.launch()
        
        addTodoInCategoryOverview()
         
        deleteCategory(categoryName: cat1, deletionOk: false)
        
        dragTodo()
        
        deleteCategory(categoryName: cat2, deletionOk: false)
        
        deleteTodo()
        
        deleteCategory(categoryName: cat2)
        deleteCategory(categoryName: cat1)
    }
    
    func testAddCategoryValidation() throws {
        let cat: String = "Privat"
        
        addCategory()
        
        let menuButton = app.buttons["ClaraMenu"]
        XCTAssertTrue(menuButton.waitForExistence(timeout: 2), "Menü-Button nicht gefunden")
        menuButton.tap()
        
        app.buttons["CategoriesListButton"].tap()
        app.buttons["CategoryAddButton"].tap()
        
        
        let nameTextField = app.textFields["CategoryFormNameTextField"]
        
        // Category mit gleichem Namen
        nameTextField.tap()
        nameTextField.typeText("Arbeit")
        
        let saveButton = app.buttons["CategoryFormSaveButton"]
        XCTAssertFalse(saveButton.isEnabled)
        
        // Name länger als 30 Zeichen
        nameTextField.doubleTap()
        nameTextField.typeText("012345678901234567890123456789A")
        
        XCTAssertFalse(saveButton.isEnabled)
        
        nameTextField.doubleTap()
        nameTextField.typeText(cat)
        saveButton.tap()
        
        app.buttons["CategoryListBackButton"].tap()
        
        deleteCategory(categoryName: cat)
        deleteCategory()
    }
    
    func addCategory(categoryName: String = "Arbeit") {
        
        let menuButton = app.buttons["ClaraMenu"]
        XCTAssertTrue(menuButton.waitForExistence(timeout: 2), "Menü-Button nicht gefunden")
        menuButton.tap()
        
        app.buttons["CategoriesListButton"].tap()
        app.buttons["CategoryAddButton"].tap()
        
        
        let nameTextField = app.textFields["CategoryFormNameTextField"]
        nameTextField.tap()
        nameTextField.typeText(categoryName)
        
        // TODO: Farbe auswählen
       
        let saveButton = app.buttons["CategoryFormSaveButton"]
        saveButton.tap()
        
        app.buttons["CategoryListBackButton"].tap()
    }
    
    func editCategory(categoryName: String = "Arbeit") {
        
        let menuButton = app.buttons["ClaraMenu"]
        XCTAssertTrue(menuButton.waitForExistence(timeout: 2), "Menü-Button nicht gefunden")
        menuButton.tap()
        
        app.buttons["CategoriesListButton"].tap()
        let categoryRow = app.staticTexts["CategoryRow_\(categoryName)"]
        categoryRow.swipeRight()
        
        let editButton = app.buttons["EditCategory"]
        XCTAssertTrue(editButton.waitForExistence(timeout: 2), "Edit-Button nicht gefunden")
        editButton.tap()
                
        let isDefaultToggle = app.switches["CategoryFormIsDefaultToggle"]
        XCTAssertTrue(isDefaultToggle.waitForExistence(timeout: 2))
        isDefaultToggle.switches.firstMatch.tap()
        
        let saveButton = app.buttons["CategoryFormSaveButton"]
        saveButton.tap()
        
        app.buttons["CategoryListBackButton"].tap()
    }
    
    func addTodo(title: String = "Neues Todo", categoryName: String = "Arbeit", useDefault: Bool = false) {
        
        app.tabBars.buttons[UITestUtils.TabNames.all].tap()
        
        let allTodosTab = app.otherElements["AllTodosTab"]
        let addButton = allTodosTab.buttons["AddTodoButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 2))
        addButton.tap()
        
        let titleTextField = app.textFields["TodoFormTitleTextField"]
        titleTextField.tap()
        titleTextField.typeText(title)
        
        if !useDefault {
            let categoryPicker = app.buttons["TodoFormCategoryPicker"]
            categoryPicker.tap()
            let categoryButton = app.buttons["CategoryPicker_\(categoryName)_Button"]
            XCTAssertTrue(categoryButton.waitForExistence(timeout: 2), "Kategorie '\(categoryName)' sollte in Form  verfügbar sein")
            categoryButton.tap()
        }
        
        let saveTodoButton = app.buttons["TodoFormSaveButton"]
        saveTodoButton.tap()
    }
    
    func addTodayTodo(title: String = "Neues Todo", categoryName: String = "Arbeit", useDefault: Bool = false) {
        
        app.tabBars.buttons[UITestUtils.TabNames.today].tap()
        
        let todayTab = app.otherElements["TodayTab"]
        let addButton = todayTab.buttons["AddTodayTodoButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 2))
        addButton.tap()
        
        let titleTextField = app.textFields["TodayTodoFormTitleTextField"]
        titleTextField.tap()
        titleTextField.typeText(title)
        
        let saveTodoButton = app.buttons["TodaysTodoFormSaveButton"]
        saveTodoButton.tap()
    }
    
    func addTodoInCategoryOverview(title: String = "Neues Todo", categoryName: String = "Arbeit") {
        
        app.tabBars.buttons[UITestUtils.TabNames.categories].tap()
        
        let categoriesTab = app.otherElements["CategoriesTab"]
        let addButton = categoriesTab.buttons["AddTodoButtonInCategoryView"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 2))
        addButton.tap()
        
        let titleTextField = app.textFields["TodoFormTitleTextField"]
        titleTextField.tap()
        titleTextField.typeText(title)
                
        let saveTodoButton = app.buttons["TodoFormSaveButton"]
        saveTodoButton.tap()
    }
    
    
    func deleteCategory(categoryName: String = "Arbeit", deletionOk: Bool = true) {
        
        let menuButton = app.buttons["ClaraMenu"]
        
        menuButton.tap()
        app.buttons["CategoriesListButton"].tap()
        
        let categoryRow = app.staticTexts["CategoryRow_\(categoryName)"]
        XCTAssertTrue(categoryRow.waitForExistence(timeout: 2), "Kategorie '\(categoryName)' sollte in Liste verfügbar sein")
        
        categoryRow.swipeLeft(velocity: .slow)
        
        app.buttons["DeleteCategory"].tap()

        if deletionOk {
            XCTAssertFalse(app.staticTexts[categoryName].exists, "Kategorie sollte gelöscht sein")
        } else {
            app.buttons["Ok"].tap()
            XCTAssertTrue(app.staticTexts[categoryName].exists)
        }
        
        app.buttons["CategoryListBackButton"].tap()
    }
    
    func deleteTodo(title: String = "Neues Todo") {
        
        app.tabBars.buttons[UITestUtils.TabNames.all].tap()
        
        app.staticTexts[title].swipeLeft(velocity: .slow)
        sleep(2)
        app.buttons["TodoListDeleteTodo"].tap()
    }
    
    func dragTodo(title: String = "Neues Todo", categoryName: String = "Privat") {
        
        app.tabBars.buttons[UITestUtils.TabNames.categories].tap()
        
        let categoriesOverview = app.otherElements["CategoriesOverviewContainer"]
        XCTAssertTrue(
            categoriesOverview.waitForExistence(timeout: 2),
            "CategoriesOverviewView sollte sichtbar sein"
        )

        let categoryBubble = categoriesOverview.staticTexts["\(categoryName): "]
        XCTAssertTrue(categoryBubble.waitForExistence(timeout: 2), "Bubble-Text sollte sichtbar sein")
        
        let taskCell = app.cells.containing(.staticText, identifier: title).element(boundBy: 0)
        XCTAssertTrue(taskCell.waitForExistence(timeout: 2), "\(title) sollte in der Liste sichtbar sein")
        
        let taskCellFrame = taskCell.frame
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0)).withOffset(CGVector(dx: taskCellFrame.midX, dy: taskCellFrame.midY))

        let end = categoryBubble.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        start.press(forDuration: 0.5, thenDragTo: end)
        
        sleep(1)
    }
}
