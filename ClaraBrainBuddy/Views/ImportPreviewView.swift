//
//  Views/ImportPreviewView.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 01.08.25.
//

import SwiftUI

struct ImportPreviewView: View {
    let todos: [Todo]
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            List(todos) { todo in
                VStack(alignment: .leading, spacing: 4) {
                    Text(todo.title)
                        .font(.headline)
                    if let details = todo.details {
                        Text(details)
                    }
                    Text("\(Localization.labels.dueDate): \(todo.dueDate, formatter: StyleUtils.dateFormatter)")
                        .font(Font.app.tiny)
                        .foregroundColor(Color.theme.listText)
                    Text("\(Localization.labels.estimatedTime): \(todo.estimatedTime) \(Localization.labels.estimatedTimeUnit)")
                        .font(Font.app.tiny)
                        .foregroundColor(Color.theme.listText)
                }
                .foregroundColor(Color.theme.listText)
                .listRowBackground(Color.theme.listBackground)
                .font(Font.app.listItem)
                .padding(.vertical, 4)
            }
            .backgroundStyle()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(Localization.labels.previewImport)
                        .foregroundColor(Color.theme.primary)
                        .font(Font.app.title)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(Localization.labels.cancel, action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(Localization.labels.importing, action: onConfirm)
                }
            }
        }
    }
}
