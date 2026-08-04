import XCTest
import SwiftUI
import CoreData
@testable import ClaraBrainBuddy

final class TodoUtilsTests: XCTestCase {

    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        context = DataManager.shared.context
    }
    
    override func tearDown() {
        context = nil
        super.tearDown()
    }
    
    func testGetShortenednTitle_returnsShortenedTitle() {
        let todo = Todo(context: context)
        todo.title = "Todo1234567890"
        let title = TodoUtils.getShortenedTitle(todo, maxLength: 4)
        XCTAssertEqual(title, "Todo...")
    }

    
    func testGetShortenednTitle_returnsFullTitle() {
        let todo = Todo(context: context)
        todo.title = "Todo1234567890"
        let title = TodoUtils.getShortenedTitle(todo, maxLength: 14)
        XCTAssertEqual(title, "Todo1234567890")
    }
}
