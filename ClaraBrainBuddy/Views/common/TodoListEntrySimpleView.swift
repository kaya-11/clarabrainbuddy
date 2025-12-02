//
//  Views/common/TodoListEntrySimpleView.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 02.12.25.
//

import SwiftUI

struct TodoListEntrySimpleView: View {
    let todo: Todo

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(todo.title)
                .font(Font.app.listItem)
            Text("\(todo.dueDate, formatter: StyleUtils.dateFormatter)")
                    .font(Font.app.tiny)
                    .foregroundColor(.secondary)

        }
    }
}
