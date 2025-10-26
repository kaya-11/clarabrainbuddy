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
        NavigationView {
            Form {
                VStack {
                    VStack {
                        Text(title)
                            .font(Font.app.title)
                            .padding()
                            .accessibilityIdentifier("Title")
                        
                        Text(explanationText)
                            .font(Font.app.normal)
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
                                .background(Color.theme.listBackground)
                                .foregroundColor(Color.theme.listText)
                                .cornerRadius(8)
                        }
                        .buttonStyle()
                        .padding()
                    }
                }
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
                    .accessibilityIdentifier("backButton")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
