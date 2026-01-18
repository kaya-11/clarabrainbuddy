//
//  Views/TodayTodos/CompletedTodosBadge.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 28.09.25.
//

import SwiftUI

struct CompletedTodosBadge: View {
    
    @ObservedObject var todoViewModel: TodoViewModel
    
    let count: Int
    let totalTime: Int64
    
    
    @State private var showingInfoView = false
    
    var body: some View {
        
        return Group {
            if (count > 0) {
                ZStack(alignment: .topTrailing) {
                    Button(action: {
                        showingInfoView = true
                    }) {
                        Image(systemName: "checkmark.circle")
                    }
                    .accessibilityIdentifier("CompletedTodosBadgeCheckmarkCircle")
                    .sheet(isPresented: $showingInfoView) {
                        InfoView(
                            isPresented: $showingInfoView,
                            title: Localization.labels.todosDoneTitle,
                            explanationText: "\(count) \(Localization.labels.todosDone)! \n\(Localization.labels.timeNeeded): \(formattedTime(totalTime))",
                            buttonText: Localization.labels.deleteCompletedTodos,
                            buttonAction: {
                                todoViewModel.deleteCompletedTodos()
                            }
                        )
                    }
                }
            }
        }
    }

    private func formattedTime(_ minutes: Int64) -> String {
        let hours = Int(minutes) / 60
        let minutes = (Int(minutes) % 60)
        if (hours == 0) {
           return "\(minutes)m"
        }
        return "\(hours)h \(minutes)m"
    }
}
