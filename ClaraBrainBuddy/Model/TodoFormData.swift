//
//  Model/TodoFormData.swift
//  ClaraBrainBuddy
//


import Foundation

struct TodoFormData {
    var title: String
    var details: String
    var dueDate: Date
    var estimatedTime: Int64?
    var energyImpact: Int64?
    var isDone: Bool
    var category: Category?
}
