//
//  Extensions/BackgroundStyle.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 20.03.25.
//

import SwiftUI

struct SectionStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowBackground(Color.theme.surfaceGlassColor.opacity(0.8))
            .foregroundColor(Color.theme.surfaceGlassTextColor)
            .accentColor(Color.theme.accent)
            .font(Font.app.section)
    }
}

struct ClaraBackground: ViewModifier {
    func body(content: Content) -> some View {
       content
            .background(Color.theme.background.ignoresSafeArea())
    }
}

struct ButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
       content
            .buttonStyle(.borderedProminent)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
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
    
    func appTheme() -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .scrollContentBackground(.hidden)
            .modifier(ClaraBackground())
    }
    
    func sectionSytle() -> some View {
        self.modifier(SectionStyle())
    }
    
    func buttonStyle() -> some View {
        self.modifier(ButtonStyle())
    }
    
}


