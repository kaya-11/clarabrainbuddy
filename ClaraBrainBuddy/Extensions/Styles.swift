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

struct Battery50Icon: View {
    
    var size : CGFloat = 24.0
    
    var body: some View {
        Image(systemName: "battery.50percent")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .symbolRenderingMode(.palette)
            .foregroundStyle(
                Color.theme.red,
                Color.theme.primary
            )
    }
}

struct Battery100Icon: View {
    
    var size : CGFloat = 24.0
    
    var body: some View {
        Image(systemName: "battery.100percent")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .symbolRenderingMode(.palette)
            .foregroundStyle(
                Color.theme.green,
                Color.theme.primary
            )
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


