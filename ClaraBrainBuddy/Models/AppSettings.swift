//
//  Model/AppSettings.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 03.05.25.
//

import Foundation

struct AppSettings: Codable, Equatable {
    var maxTodosForToday: Int
    var defaultEstimatedTimeForRecurringTasks: Int
    var defaultTimeForEnergyLevelCalculation: Int
    var daysAddedForDefaultDueDate: Int
}
