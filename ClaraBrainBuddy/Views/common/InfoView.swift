//
//  Views/common/InfoView.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 12.10.25.
//

import SwiftUI

struct InfoView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var isPresented: Bool
    
    let title: String
    let explanationText: String
    let buttonText: String?
    let buttonAction: (() -> Void)?

    var body: some View {
        NavigationStack {
            Form {
                VStack {
                    VStack {
                        Text(title)
                            .font(Font.app.normal)
                            .padding()
                            .accessibilityIdentifier("Title")
                        
                        Text(explanationText)
                            .font(Font.app.small)
                            .padding()
                            .accessibilityIdentifier("Explanation")
                        
                    }
                    .sectionSytle()
                    
                    if let buttonText = buttonText, let buttonAction = buttonAction {
                        Button(action: {
                            buttonAction()
                            isPresented = false
                        }) {
                            Text(buttonText)
                                .font(Font.app.button)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .listRowBackground(Color.theme.listBackground)
                                .foregroundColor(Color.theme.accent)
                                .cornerRadius(8)
                        }
                        .buttonStyle()
                        .padding()
                    }
                }
                .sectionSytle()
                .foregroundColor(Color.theme.primary)
            }
            .appTheme()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(Localization.labels.back)
                            .font(Font.app.button)
                    }
                    .accessibilityIdentifier("backButton")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
