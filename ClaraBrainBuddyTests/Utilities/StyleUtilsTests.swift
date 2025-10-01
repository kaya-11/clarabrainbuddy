import XCTest
import SwiftUI
import CoreData
@testable import ClaraBrainBuddy

final class StyleUtilsTests: XCTestCase {

    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        context = DataManager.shared.context
    }
    
    override func tearDown() {
        context = nil
        super.tearDown()
    }
    
    func testDone_returnsGreen() {
        let todo = Todo(context: context)
        todo.title = "Done Todo"
        todo.isDone = true
        let color = StyleUtils.getTextColor(todo: todo, isSelectedForToday: false)
        XCTAssertEqual(color, Color.theme.green)
    }

    func testSelectedForToday_returnsBlue() {
        let todo = Todo(context: context)
        todo.title = "Today Todo"
        let color = StyleUtils.getTextColor(todo: todo, isSelectedForToday: true)
        XCTAssertEqual(color, Color.theme.blue)
    }

    func testOverdue_returnsRed() {
        let pastDate = Calendar.current.date(byAdding: .day, value: -8, to: Date())!
        let todo = Todo(context: context)
        todo.title = "Overdue Todo"
        todo.dueDate = pastDate
        let color = StyleUtils.getTextColor(todo: todo, isSelectedForToday: false)
        XCTAssertEqual(color, Color.theme.red)
    }

    func testDueSoon_returnsAccent() {
        let soonDate = Calendar.current.date(byAdding: .day, value: 2, to: Date())!
        let todo = Todo(context: context)
        todo.title = "Due Soon Todo"
        todo.dueDate = soonDate
        let color = StyleUtils.getTextColor(todo: todo, isSelectedForToday: false)
        XCTAssertEqual(color, Color.theme.accent)
    }

    func testDefault_returnsListText() {
        let futureDate = Calendar.current.date(byAdding: .day, value: 10, to: Date())!
        let todo = Todo(context: context)
        todo.title = "Future Todo"
        todo.dueDate = futureDate
        let color = StyleUtils.getTextColor(todo: todo, isSelectedForToday: false)
        XCTAssertEqual(color, Color.theme.listText)
    }
    
    func testDateFormatter() {
        XCTAssertEqual(StyleUtils.dateFormatter.dateFormat, "dd.MM.y")
    }
    
    func testDateTimeFormatter() {
        XCTAssertEqual(StyleUtils.dateTimeFormatter.dateFormat, "yyyyMMdd_HHmmss")
    }
    
    func testIconFontSizeForLevels() {
        XCTAssertEqual(StyleUtils.iconFontSizeForLevels(for: 3), .system(size: 6))
        XCTAssertEqual(StyleUtils.iconFontSizeForLevels(for: 4), .system(size: 8))
        XCTAssertEqual(StyleUtils.iconFontSizeForLevels(for: 6), .system(size: 8))
        XCTAssertEqual(StyleUtils.iconFontSizeForLevels(for: 7), .system(size: 10))
    }
   
    func testIconColorForLevels() {
        XCTAssertEqual(StyleUtils.iconFontColorForLevels(for: 3), Color.theme.listText)
        XCTAssertEqual(StyleUtils.iconFontColorForLevels(for: 4), Color.theme.accent)
        XCTAssertEqual(StyleUtils.iconFontColorForLevels(for: 6), Color.theme.accent)
        XCTAssertEqual(StyleUtils.iconFontColorForLevels(for: 7), Color.theme.red)
    }
    
}
