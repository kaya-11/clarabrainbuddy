//
//  Extensions/BackgroundStyle.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 20.03.25.
//

import SwiftUI

struct BackgroundStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .foregroundColor(Color.theme.primary)
            .accentColor(Color.theme.accent)
            .background(Color.theme.background)
    }
}

extension View {
    func backgroundStyle() -> some View {
        self.modifier(BackgroundStyle())
    }
}


