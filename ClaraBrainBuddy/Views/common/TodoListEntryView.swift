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
    
    let isInTodayView: Bool
    
    let showSymbols: Bool
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
        let category: Category? = todo.category
        
        VStack(alignment: .leading, spacing: 4) {
            HStack (alignment: .firstTextBaseline, spacing: 8) {
                if let cat = category {
                    ColorCircleView(hex: cat.color, size: 6)
                    Text("\(cat.name): ")
                        .foregroundColor(Color.theme.surfaceGlassTextColor)
                    }
                
                if isDone {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.theme.green)
                } else if !isInTodayView && showSymbols {
                    if showAsSelectedForToday {
                        Image(systemName: "wind")
                    } else if isOverdue {
                        Image(systemName: "cloud.drizzle.fill")
                    } else if isDueSoon {
                        Image(systemName: "leaf")
                    }
                }

                Text(title)
                    .accessibilityValue(isDone ? "done" : "active")
                
                let showEnergyImpact = showSymbols || isInTodayView
                if (showEnergyImpact && todo.energyImpact < 0) {
                    Battery50Icon(size: 12.0)
                        .rotationEffect(.degrees(-90))
                } else if (showEnergyImpact && todo.energyImpact > 0) {
                    Battery100Icon(size: 12.0)
                        .rotationEffect(.degrees(-90))
                }
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
