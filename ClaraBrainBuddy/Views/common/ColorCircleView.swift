//
//  View/common/ColorCircleView.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 20.12.25.
//


import SwiftUI

struct ColorCircleView: View {
    
    let hex: String
    let size: CGFloat

    init(hex: String, size: CGFloat = 20) {
        self.hex = hex
        self.size = size
    }

    var body: some View {
        Circle()
            .fill(Color(hex: hex))
            .frame(width: size, height: size)
            .shadow(radius: 2)
    }
}

extension ColorCircleView {
    func selectable(selectedColorHex: Binding<String>) -> some View {
        self
            .overlay(
                Circle()
                    .stroke(selectedColorHex.wrappedValue == hex ? Color.theme.primary : Color.clear, lineWidth: 3)
            )
            .onTapGesture {
                selectedColorHex.wrappedValue = hex
            }
    }
}
