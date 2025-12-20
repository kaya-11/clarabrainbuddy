//
//  Views/common/CategoryPickerView.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 20.12.25.
//


import SwiftUI
import CoreData

struct CategoryPickerView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default)
    private var categories: FetchedResults<Category>

    @Binding var selectedCategory: Category?

    init(selectedCategory: Binding<Category?>, showNoneOption: Bool = true) {
        self._selectedCategory = selectedCategory
    }

    var body: some View {
        Menu {
            Button(action: { selectedCategory = nil }) {
                Text(Localization.labels.categoryNone)
            }
            ForEach(categories, id: \.self) { category in
                Button(action: { selectedCategory = category }) {
                    Text(category.name)
                }
            }
        } label: {
            HStack {
                if let category = selectedCategory {
                    ColorCircleView(hex: category.color, size: 15)
                }
                Text(selectedCategory?.name ?? Localization.labels.selectCategory)
                Spacer()
                Image(systemName: "chevron.down")
            }
        }
        .onAppear {
            if selectedCategory == nil {
                if let defaultCategory = categories.first(where: { $0.isDefault }) {
                    selectedCategory = defaultCategory
                }
            }
        }
    }
}
