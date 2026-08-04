//
//  Views/Categories/CategoryBubbleView.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 05.01.26.
//
import SwiftUI
import UniformTypeIdentifiers

struct CategoryBubbleView: View {
    @ObservedObject var category: Category
    
    @State private var isTargeted = false
    
    var onDrop: ([NSItemProvider], Category) -> Bool

    var body: some View {
        HStack {
            let truncatedName = String(category.name).count > 26 ? String(category.name.prefix(20)) + "..." : category.name
            Text("\(truncatedName): ")
                .font(Font.app.tiny)
                .foregroundColor(Color.theme.primary)
            Text("\(category.todos.count)")
                .font(Font.app.normal)
                .bold()
                .foregroundColor(Color.theme.primary)
                .padding(4)
        }
        .frame(width: 150, height: 60)
        .background(
            isTargeted
                  ? Color.theme.secondary.opacity(0.25)
                  : Color.theme.surfaceGlassColor
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: category.color).opacity(isTargeted ? 1.0 : 0.6),
                        lineWidth: isTargeted ? 5 : 4)
        )
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .onDrop(of: [UTType.text], isTargeted: $isTargeted) { providers in
            onDrop(providers, category)
        }
    }
}
