//
//  Views/AllTodos/TodoFormView.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//

import SwiftUI
import Foundation

struct CategoryFormView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var categoryViewModel: CategoryViewModel
    
    // If nil → Add Mode | If non-nil → Edit Mode
    var existingCategory: Category?

    @State private var name: String = ""
    @State private var color: String = ""
    @State private var isDefault: Bool = false
    
    init(categoryViewModel: CategoryViewModel, existingCategory: Category?) {
        self.categoryViewModel = categoryViewModel
        self.existingCategory = existingCategory

        // Initialize the state variables
        if let category = existingCategory {
            _name = State(initialValue: category.name)
            _color = State(initialValue: category.color ?? "")
            _isDefault = State(initialValue: category.isDefault)
        } else {
            _color = State(initialValue: "616161")
            _isDefault = State(initialValue: false)
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(Localization.labels.categoryName)) {
                    TextField(Localization.labels.categoryNameTooltip, text: $name)
                        .foregroundColor(Color.theme.primary)
                        .accessibilityIdentifier("CategoryFormNameTextField")
                }
                .sectionSytle()

                Section(header: Text(Localization.labels.categoryColor)) {
                    Grid(horizontalSpacing: 8, verticalSpacing: 8) {
                        GridRow {
                            ForEach(Array(CategoryColor.allCases.prefix(9)), id: \.self) { color in
                                colorCircle(hex: color.hex)
                            }
                        }
                        GridRow {
                            ForEach(Array(CategoryColor.allCases.dropFirst(9)), id: \.self) { color in
                                colorCircle(hex: color.hex)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .sectionSytle()
                
                Section(header: Text(Localization.labels.categoryDefault)) {
                    Toggle(Localization.labels.categoryDefault, isOn: $isDefault)
                        .accessibilityIdentifier("CategoryFormIsDefaultToggle")
                }
                .sectionSytle()
                
                Button(action: {
                    if let category = existingCategory {
                        updateCategory(category)
                    } else {
                        categoryViewModel.addCategory(name: name, color: color, isDefault: isDefault)
                    }
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text(existingCategory == nil ? Localization.labels.saveAddCategory :  Localization.labels.saveEditCategory).accessibilityLabel("CategoryFormSaveButton")
                }
                .buttonStyle()
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
            }
            .backgroundStyle()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(existingCategory == nil ? Localization.labels.addCategory : Localization.labels.editCategory)
                        .foregroundColor(Color.theme.primary)
                        .font(Font.app.title)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private func colorCircle(hex: String) -> some View {
        Circle()
            .fill(Color(hex: hex))
            .frame(width: 30, height: 30)
            .overlay(
                Circle()
                    .stroke(color == hex ? Color.theme.primary : Color.clear, lineWidth: 2)
            )
            .onTapGesture {
                color = hex
            }
    }
    
    func updateCategory(_ category: Category) {
        let updatedCategory = category
        updatedCategory.name = name
        updatedCategory.color = color
        updatedCategory.isDefault = isDefault
        categoryViewModel.updateCategory(updatedCategory)
    }
}
