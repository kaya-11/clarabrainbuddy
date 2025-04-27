//
//  Views/SettingsView.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 27.04.25.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title: String = ""
    @State private var details: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(Localization.labels.titleForm)) {
                    TextField(Localization.labels.titleFormTooltip, text: $title)
                        .foregroundColor(Color.theme.primary)
                }
                
                Section(header: Text(Localization.labels.details)) {
                    TextEditor(text: $details)
                        .frame(height: 120)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray.opacity(0.3)))
                }
                
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text(Localization.labels.save)
                }
                .font(Font.app.button)

            }
            .backgroundStyle()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(Localization.labels.back)
                            .font(Font.app.button)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(Localization.labels.properties)
                        .foregroundColor(Color.theme.primary)
                        .font(Font.app.title)
                }
            }
        }
    }
}
