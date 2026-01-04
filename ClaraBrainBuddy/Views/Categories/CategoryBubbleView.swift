//
//  Views/Categories/CategoryBubbleView.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 05.01.26.
//
import SwiftUI

struct CategoryBubbleView: View {
    @ObservedObject var category: Category

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
        .frame(minWidth: 150, minHeight: 60)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: category.color).opacity(0.6), lineWidth: 4)
        )
    }
}
