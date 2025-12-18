//
//  Extensions/CategoryColor.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 20.12.25.
//

import SwiftUI

enum CategoryColor: String, CaseIterable, Identifiable {
    case darkGray = "616161"
    case anthracite = "424242"
    case pastelYellow = "FFF59D"
    case mediumYellow = "FFEB3B"
    case pastelOrange = "FFCC80"
    case mediumOrange = "FF9800"
    case pastelRed = "FFAB91"
    case mediumRed = "F44336"
    case pastelPurple = "CE93D8"
    case lightGray = "F5F5F5"
    case mediumGray = "E0E0E0"
    case pastelBlue = "90CAF9"
    case mediumBlue = "2196F3"
    case pastelTeal = "4DD0E1"
    case mediumTeal = "00BCD4"
    case pastelGreen = "A5D6A7"
    case mediumGreen = "4CAF50"
    case mediumPurple = "9C27B0"

    var id: String { rawValue }
    var hex: String { rawValue }
    var color: Color { Color(hex: rawValue) }
}

enum CategoryColorGroup: String, CaseIterable {
    case grays, yellows, oranges, reds, purples, blues, teals, greens

    var colors: [CategoryColor] {
        switch self {
        case .grays: return [.darkGray, .anthracite, .lightGray, .mediumGray]
        case .yellows: return [.pastelYellow, .mediumYellow]
        case .oranges: return [.pastelOrange, .mediumOrange]
        case .reds: return [.pastelRed, .mediumRed]
        case .purples: return [.mediumPurple, .pastelPurple]
        case .blues: return [.pastelBlue, .mediumBlue]
        case .teals: return [.pastelTeal, .mediumTeal]
        case .greens: return [.pastelGreen, .mediumGreen]
        }
    }
}
