//
//  Views/CompletedTodosBadge.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 28.09.25.
//


import SwiftUI

struct CompletedTodosBadge: View {
    let count: Int
    let totalTime: Int64
    
    @State private var showingTooltip = false
    

    var body: some View {
        
        return Group {
            if (count > 0) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.theme.accent)
                        .onLongPressGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showingTooltip = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showingTooltip = false
                                }
                            }
                    }
                    .accessibilityIdentifier("CompletedTodosBadgeCheckmarkCircleFill")
                }
                .overlay(
                    ZStack {
                        if showingTooltip {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("\(count) \(Localization.labels.todosDone)!")
                                Text("\(Localization.labels.timeNeeded): \(formattedTime(totalTime))")
                            }
                            .font(Font.app.tiny)
                            .padding(4)
                            .frame(width: 150, height: 60)
                            .background(Color.theme.listBackground)
                            .cornerRadius(8)
                            .offset(x: 75, y: 45)  // Position relativ zum Icon
                            .transition(.opacity)
                        }
                    }
                )
            } else {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(Color.theme.accent)
                    .accessibilityIdentifier("CompletedTodosBadgeCheckmarkCircle")
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
