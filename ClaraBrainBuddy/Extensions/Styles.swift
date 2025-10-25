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

struct InputFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowBackground(Color.theme.listBackground)
            .foregroundColor(Color.theme.listText)
            .accentColor(Color.theme.accent)
            .font(Font.app.section)
    }
}

struct ButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowBackground(Color.theme.listBackground)
            .foregroundColor(Color.theme.listText)
            .accentColor(Color.theme.accent)
            .font(Font.app.button)
    }
}

extension View {
    func backgroundStyle() -> some View {
        self.modifier(BackgroundStyle())
    }
    
    func sectionSytle() -> some View {
        self.modifier(InputFieldStyle())
    }
    
    func buttonStyle() -> some View {
        self.modifier(ButtonStyle())
    }
}


