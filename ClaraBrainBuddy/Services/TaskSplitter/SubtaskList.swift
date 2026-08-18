//
//  Services/TaskSplitter/SubtaskList.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 18.08.26.
//

import Foundation
import SwiftUI
import FoundationModels

@available(iOS 26.0, *)
@Generable
struct SubtaskList {
    @Guide(description: "Die Teilaufgaben in sinnvoller Reihenfolge", .count(3...10))
    let subtasks: [GeneratedSubtask]
}
