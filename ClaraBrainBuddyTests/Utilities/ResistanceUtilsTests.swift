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
    
    func testIncreaseResistance_returnsMaxNineteen() {
        let resistance = ResistanceUtils.increaseResistance(resistance: 19)
        XCTAssertEqual(19, resistance)
    }
    
    func testIncreaseResistance_returnsOneMore() {
        let resistance = ResistanceUtils.increaseResistance(resistance: 18)
        XCTAssertEqual(19, resistance)
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
