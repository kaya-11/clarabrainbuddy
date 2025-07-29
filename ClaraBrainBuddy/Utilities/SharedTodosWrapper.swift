//
//  Utilities/SharedTodosWrapper.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 17.06.25.
//

import SwiftUI

struct SharedTodosWrapper: Identifiable {
    let id = UUID()
    let todos: [Todo]
}
