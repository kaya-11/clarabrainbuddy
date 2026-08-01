//
//  Views/PriorityMatrix/PriorityDropView.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 05.12.25.
//

import SwiftUI
import UniformTypeIdentifiers
import CoreData

struct PriorityDropView: View {

    let priority: PriorityMatrix
    
    @Binding var tasks: [Todo]
    
    let onDropTodo: (String) -> Void
    
    @State private var isTargeted = false
    
    var body: some View {
        VStack (alignment: .leading, spacing: 8) {
            Text(priority.localizedString)
                .font(Font.app.normal)
                .foregroundColor(Color.theme.accent)
                .frame(maxWidth: .infinity, alignment: .leading)

            
            if !tasks.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(tasks) { task in
                            TodoListEntrySimpleView(todo: task)
                                .font(Font.app.tiny)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                                .onDrag {
                                    NSItemProvider(object: String(task.objectID.uriRepresentation().absoluteString) as NSString)
                                } preview: {
                                    Text(task.title.count > 10 ? String(task.title.prefix(10) + "...") : task.title)
                                        .font(Font.app.tiny)
                                        .lineLimit(1)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                }
                        }
                    }
                }
                .frame(maxHeight: 130)
            }
            
            Spacer(minLength: 0)
        }
        .padding(8)
        .frame(width: 170, height: 180)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isTargeted
                      ? Color.theme.secondary.opacity(0.25)
                      : Color.theme.surfaceGlassColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isTargeted ? Color.theme.accent : Color.theme.secondary,
                        lineWidth: isTargeted ? 3 : 2)
        )
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .onDrop(of: [UTType.text], isTargeted: $isTargeted) { providers in
            handleDrop(providers)
        }
    }
    
    
    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        provider.loadItem(forTypeIdentifier: UTType.text.identifier) { item, _ in
            DispatchQueue.main.async {
                if let data = item as? Data {
                    onDropTodo(String(decoding: data, as: UTF8.self))
                } else if let string = item as? String {
                    onDropTodo(string)
                } else if let nsString = item as? NSString {
                    onDropTodo(nsString as String)
                }
            }
        }
        return true
    }
}
