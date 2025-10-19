//
//  View/Menu/AboutView.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 28.09.25.
//


import SwiftUI

struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading, spacing: 16) {
                    Text(Localization.about.claraBrainBuddyTitle)
                                        .font(Font.app.normal)
                                        .bold()
                                        .padding(.top, 4)
                    
                    // Beschreibung
                    Text(Localization.about.claraBrainBuddyDescription)
                        .font(Font.app.tiny)
                    
                    // Features
                    featureSection(
                        title: Localization.about.featureTodosTitle,
                        description: Localization.about.featureTodosDescription
                    )
                    featureSection(
                        title: Localization.about.featureRecurringTasksTitle,
                        description: Localization.about.featureRecurringTasksDescription
                    )
                    featureSection(
                        title: Localization.about.featureHapticFeedbackTitle,
                        description: Localization.about.featureHapticFeedbackDescription
                    )
                    featureSection(
                        title: Localization.about.featureSortTitle,
                        description: Localization.about.featureSortDescription
                    )
                    featureSection(
                        title: Localization.about.featureFeedbackTitle,
                        description: Localization.about.featureFeedbackDescription
                    )
                    featureSection(
                        title: Localization.about.featureSharingTitle,
                        description: Localization.about.featureSharingDescription
                    )
                    featureSection(
                        title: Localization.about.featureSearchTitle,
                        description: Localization.about.featureSearchDescription
                    )
                    featureSection(
                        title: Localization.about.featureTaskSetsTitle,
                        description: Localization.about.featureTaskSetsDescription
                    )
                    featureSection(
                        title: Localization.about.featureNeurodivergentTitle,
                        description: Localization.about.featureNeurodivergentDescription
                    )
                    
                    // Entwickler und Copyright
                    VStack(alignment: .leading, spacing: 0) {
                        Text(Localization.about.developer)
                        Text(Localization.about.copyright)
                    }
                    .italic()
                    .font(Font.app.tiny)
                    
                    // Geplante Erweiterungen
                    Text(Localization.about.plannedExtensionsTitle)
                        .font(Font.app.normal)
                        .bold()
                        .padding(.top, 4)
                    
                    // Geplante Features
                    featureSection(
                        title: Localization.about.featureCategoriesTitle,
                        description: Localization.about.featureCategoriesDescription
                    )
                    featureSection(
                        title: Localization.about.featureAISupportTitle,
                        description: Localization.about.featureAISupportDescription
                    )
                    
                    // Hinweis
                    Text(Localization.about.plannedNote)
                        .font(Font.app.tiny)
                        .italic()
                        .padding(.top, 4)
                }
                .sectionSytle()
                .foregroundColor(Color.theme.primary)
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
            }
        }
    }

    @ViewBuilder
    private func featureSection(title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(Font.app.tiny)
                .bold()
            Text(description)
                .font(Font.app.tiny)
        }
    }
        
}
