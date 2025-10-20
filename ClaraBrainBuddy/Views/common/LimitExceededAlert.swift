//
//  Views/common/LimitExceededAlert.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 20.10.25.
//


import SwiftUI

struct LimitExceededAlert: View {
    let maxTodos: Int

    var body: some View {
        EmptyView()
    }

    func alert() -> Alert {
        Alert(
            title: Text(Localization.messages.limitExeeded),
            message: Text(String(format: Localization.messages.limitExeededMessage, "\(maxTodos)")),
            dismissButton: .default(Text(Localization.labels.ok))
        )
    }
}
