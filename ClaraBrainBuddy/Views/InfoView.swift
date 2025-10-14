//
//  Views/InfoView.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 12.10.25.
//

import SwiftUI

struct InfoView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let title: String
    let explanationText: String
    let buttonText: String

    var body: some View {
        NavigationView {
            Form {
                VStack {
                    Text(title)
                        .font(Font.app.title)
                        .padding()
                    
                    Text(explanationText)
                        .font(Font.app.normal)
                        .padding()
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
        }
    }
}
