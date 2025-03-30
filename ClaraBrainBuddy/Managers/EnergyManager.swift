//
//  Manager/EnergyManager.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 26.03.25.
//

class EnergyManager {
    
    static let MAX_ESTIMATED_TIME_LOW : Int = 90
    static let MAX_ESTIMATED_TIME_MEDIUM : Int = 150
    static let MAX_ESTIMATED_TIME_HIGH : Int = 210

    enum EnergyLevel: Float {
        case low = 1.0
        case medium = 2.0
        case high = 3.0
    }

    static func getMaxEstimatedTime(energyLevel: Float) -> Int {
        switch energyLevel {
            case EnergyLevel.low.rawValue:
                return MAX_ESTIMATED_TIME_LOW
            case EnergyLevel.medium.rawValue:
                return MAX_ESTIMATED_TIME_MEDIUM
            case EnergyLevel.high.rawValue:
                return MAX_ESTIMATED_TIME_HIGH
            default:
                return 0
        }
    }
}
