//
//  Utilities/ResistanceUtils.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 15.07.26.
//

import SwiftUI

struct ResistanceUtils {
    
    static func increaseResistance(resistance: Int64) -> Int64 {
        var r = resistance
        if r <= 11 { r += 1 }
        return r
    }
    
    static func decreaseResistance(resistance: Int64) -> Int64 {
        var r = resistance
        if r > 0 { r -= 1 }
        return r
    }
}
