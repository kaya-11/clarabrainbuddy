//
//  Views/ClaraIconSubmenu.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 27.04.25.
//

import SwiftUI

struct ClaraMenuView: View {
    
    @ObservedObject var settingsViewModel: SettingsViewModel
    @ObservedObject var todoViewModel: TodoViewModel
    
    @State private var isSettingsPresented = false
    @State private var isTodaysEventsPresented = false

    
    var body: some View {
        Menu {
            
            Button(action: {
                isTodaysEventsPresented = true
            }) {
                Text("Today's Events")
            }
            
            Button(action: {
                if let url = URL(string: "calshow://") {
                    UIApplication.shared.open(url)
                }
            }) {
                Text(Localization.labels.openCalendar)
            }
            
            Button(action: {
                isSettingsPresented = true
            }) {
                Text(Localization.labels.properties)
            }

        
        } label: {
            Image(systemName: "line.horizontal.3")
                .foregroundColor(Color.theme.accent)
        }
        .fullScreenCover(isPresented: $isSettingsPresented) {
            SettingsView(settingsViewModel: settingsViewModel)
        }
        .fullScreenCover(isPresented: $isTodaysEventsPresented) {
            CalendarView(todoViewModel: todoViewModel)
        }
    }
}
