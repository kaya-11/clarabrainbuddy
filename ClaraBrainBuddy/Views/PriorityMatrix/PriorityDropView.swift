//
//  Views/PriorityMatrix/PriorityDropView.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 05.12.25.
//
import SwiftUI

struct PriorityDropView: View {

    let priority: PriorityMatrix
    
    @Binding var tasks: [Todo]
    
    var body: some View {
        VStack (alignment: .leading, spacing: 8) {
            Text(priority.localizedString)
                .font(Font.app.normal)
                .foregroundColor(Color.theme.accent)
                .frame(maxWidth: .infinity, alignment: .leading)

            
            if !tasks.isEmpty {
                List {
                    ForEach(tasks) { task in
                        TodoListEntrySimpleView(todo: task)
                            .font(Font.app.tiny)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                            .onDrag {
                                NSItemProvider(object: String(task.objectID.uriRepresentation().absoluteString) as NSString)
                            }
                    }
                }
                .listStyle(.plain)
                .frame(maxHeight: 130)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(8)
        .frame(minWidth: 170, maxWidth: .infinity, minHeight: 180, maxHeight: 180)
        .background(Color.theme.listBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.theme.secondary, lineWidth: 2)
        )
        .contentShape(RoundedRectangle(cornerRadius: 12))
    }
}
