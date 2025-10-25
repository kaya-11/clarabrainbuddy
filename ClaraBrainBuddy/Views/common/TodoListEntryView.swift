//
//  TodoListEntryView.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 19.10.25.
//


import SwiftUI

struct TodoListEntryView: View {
    @ObservedObject var todoViewModel: TodoViewModel
    
    let todo: Todo
    let showAsSelectedForToday: Bool
    
    let withEmojis: Bool
    
    let showEmojis: Bool
    let showDueDate: Bool
    
    let showResistance: Bool
    
    @State private var viewID = UUID()

    var body: some View {
        let isDone: Bool = todo.isDone
        let title: String = todo.title
        let details: String = todo.details ?? ""
        let dueDate: Date = todo.dueDate
        let isOverdue: Bool = todo.isOverdue
        let isDueSoon: Bool = todo.isDueSoon
        let resistance: Int64 = todo.resistance
        
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if isDone {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.theme.green)
                } else if withEmojis && showEmojis {
                    if showAsSelectedForToday {
                        Text("🐿️")
                    } else if isOverdue {
                        Text("🦥")
                    } else if isDueSoon {
                        Text("🐶")
                    }
                } else {
                    if showEmojis && isOverdue {
                        Text("🦥")
                    }
                }
                Text(title + (isOverdue && !showAsSelectedForToday ? " ‼️" : ""))
                    .accessibilityValue(isDone ? "done" : "active")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if !details.isEmpty {
                Text(String(details.prefix(20)) + (details.count > 20 ? "..." : ""))
                    .font(Font.app.tiny)
                    .foregroundColor(Color.theme.secondary)
            }
            
            if showDueDate {
                Text("\(Localization.labels.due): \(dueDate, formatter: StyleUtils.dateFormatter)")
                    .font(Font.app.tiny)
                    .foregroundColor(Color.theme.secondary)
            }
            
            if showResistance && Int(resistance) > 0 {
                TaskResistanceView(resistance: Int(resistance))
            }
        }
        .id(viewID)
        .onReceive(todoViewModel.objectWillChange) { _ in
            viewID = UUID()
        }
    }
}
