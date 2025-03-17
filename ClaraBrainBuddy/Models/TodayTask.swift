//
//  Models/TodayTask.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 18.03.25.
//
import Foundation

struct TodayTask: Identifiable, Codable  {
    let id: UUID
    var taskId: UUID?
    var isDone: Bool
}
