//
//  Views/ClaraIconSubmenu.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 27.04.25.
//

import SwiftUI

struct ClaraMenuView: View {
    
    @ObservedObject var settingsViewModel: SettingsViewModel
    
    @State private var isSettingsPresented = false

    
    var body: some View {
        Menu {
            Button(action: {
                isSettingsPresented = true
            }) {
                Text(Localization.labels.properties)
            }
            Button(action: {
                if let url = URL(string: "calshow://") {
                    UIApplication.shared.open(url)
                }
            }) {
                Text(Localization.labels.openCalendar)
            }
        } label: {
            Image(systemName: "line.horizontal.3")
                .foregroundColor(Color.theme.accent)
        }
        .fullScreenCover(isPresented: $isSettingsPresented) {
            SettingsView(settingsViewModel: settingsViewModel)
        }
    }
}
