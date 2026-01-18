//
//  Views/AllTodos/CategoryFormView.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//

import SwiftUI
import Foundation

struct CategoryFormView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var categoryViewModel: CategoryViewModel
    
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
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
            _color = State(initialValue: category.color)
            _isDefault = State(initialValue: category.isDefault)
        } else {
            _color = State(initialValue: CategoryColor.darkGray.hex)
            _isDefault = State(initialValue: false)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(Localization.labels.categoryName)) {
                    TextField(Localization.labels.categoryNameTooltip, text: $name)
                        .foregroundColor(Color.theme.primary)
                        .background(showError ? Color.red.opacity(0.2) : nil)
                        .accessibilityIdentifier("CategoryFormNameTextField")
                        .onChange(of: name) {
                            validateName(name)
                        }
                    if showError {
                        Text(errorMessage)
                            .foregroundColor(Color.theme.red)
                            .font(Font.app.small)
                    }
                    
                }
                .sectionSytle()


                Section(header: Text(Localization.labels.categoryColor)) {
                    Grid(horizontalSpacing: 8, verticalSpacing: 8) {
                        GridRow {
                            ForEach(Array(CategoryColor.allCases.prefix(9)), id: \.self) { color in
                                ColorCircleView(hex: color.hex, size: 30)
                                    .selectable(selectedColorHex: $color)
                            }
                        }
                        GridRow {
                            ForEach(Array(CategoryColor.allCases.dropFirst(9)), id: \.self) { color in
                                ColorCircleView(hex: color.hex, size: 30)
                                    .selectable(selectedColorHex: $color)
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
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || showError)
                    
            }
            .appTheme()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(existingCategory == nil ? Localization.labels.addCategory : Localization.labels.editCategory)
                        .foregroundColor(Color.theme.primary)
                        .font(Font.app.header)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func validateName(_ name: String) {
        if name.count > CategoryViewModel.MAX_LENGTH_NAME {
            showError = true
            errorMessage = Localization.errors.categoryNameLengthError
        } else if existingCategory == nil && categoryViewModel.categoryExists(name: name) {
            showError = true
            errorMessage = Localization.errors.categoryNameAlreadyExistsError
        } else {
            showError = false
            errorMessage = ""
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
