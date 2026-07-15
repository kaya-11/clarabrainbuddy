//
//  ResistanceUtilsTests.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 06.08.25.
//

import XCTest
import SwiftUI
import CoreData
@testable import ClaraBrainBuddy

final class ResistanceUtilsTests: XCTestCase {

    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        context = DataManager.shared.context
    }
    
    override func tearDown() {
        context = nil
        super.tearDown()
    }
    
    func testIncreaseResistance_returnsMaxEleven() {
        let resistance = ResistanceUtils.increaseResistance(resistance: 12)
        XCTAssertEqual(12, resistance)
    }
    
    func testIncreaseResistance_returnsOneMore() {
        let resistance = ResistanceUtils.increaseResistance(resistance: 10)
        XCTAssertEqual(11, resistance)
    }
    
    func testDecreaseResistance_returnsMinZero() {
        let resistance = ResistanceUtils.decreaseResistance(resistance: 0)
        XCTAssertEqual(0, resistance)
    }
    
    func testDecreaseResistance_returnsOneLess() {
        let resistance = ResistanceUtils.decreaseResistance(resistance: 1)
        XCTAssertEqual(0, resistance)
    }
    
}
