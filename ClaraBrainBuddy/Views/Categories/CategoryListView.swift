//
//  Views/Categories/CategoryListView.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 17.12.25.
//
import SwiftUI

struct CategoryListView: View {
    
    @ObservedObject var categoryViewModel: CategoryViewModel = .shared
    @ObservedObject var todoViewModel: TodoViewModel = .shared
    
    @Environment(\.managedObjectContext) private var context
    @Environment(\.presentationMode) var presentationMode
    
    
    @State private var showingAddCategory = false
    
    @State private var selectedCategory: Category?
    
    @State private var alertItem: CategoryAlertItem?

    @State private var searchText = ""
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Category.sortOrder, ascending: true),
            NSSortDescriptor(keyPath: \Category.updatedAt, ascending: true)
        ]
    ) private var categories: FetchedResults<Category>

    var filteredCategories: [Category] {
        if searchText.isEmpty {
            return Array(categories)
        } else {
            return categories.filter { category in
                let nameMatches = category.name.localizedCaseInsensitiveContains(searchText)
                return nameMatches
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(filteredCategories, id: \.id) { category in
                        HStack {
                            ColorCircleView(hex: category.color, size: 20)
                            Text(category.name)
                                .foregroundColor(Color.theme.primary)
                                .accessibilityIdentifier("CategoryRow_\(category.name)")
                            Spacer()
                            if category.isDefault {
                                Image(systemName: "star.fill")
                                    .foregroundColor(Color.theme.accent)
                                    .font(Font.app.listItem)
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            if categoryViewModel.isCategoryUnused(category: category) {
                                Button(role: .destructive) {
                                    do {
                                        try categoryViewModel.deleteCategory(category)
                                    } catch {
                                        print("Error deletung category: \(error.localizedDescription)")
                                        alertItem = .deletionFailed
                                    }
                                } label: {
                                    Label(Localization.labels.delete, systemImage: "trash")
                                }
                                .tint(.red)
                                .accessibilityIdentifier("DeleteCategory")
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                selectedCategory = category
                            } label: {
                                Label(Localization.labels.edit, systemImage: "pencil")
                            }
                            .tint(.green)
                            .accessibilityIdentifier("EditCategory")
                        }
                        .listRowBackground(Color.theme.listBackground)
                    }
                    .onMove(perform: move)
                }
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                .sheet(item: $selectedCategory) { category in
                    CategoryFormView(categoryViewModel: categoryViewModel, existingCategory: category).accessibilityIdentifier("CategoryFormView")
                }
                .sheet(isPresented: $showingAddCategory) {
                    CategoryFormView(categoryViewModel: categoryViewModel, existingCategory: nil)
                }
                .appTheme()
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text(Localization.labels.back) 
                                .font(Font.app.button)
                        }
                        .accessibilityIdentifier("CategoryListBackButton")
                    }
                    ToolbarItem(placement: .principal) {
                        Text(Localization.labels.categories)
                            .foregroundColor(Color.theme.primary)
                            .font(Font.app.header)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            if categoryViewModel.hasReachedMaxNumberOfCategories() {
                                alertItem = .maxCategories
                            } else {
                                showingAddCategory = true
                            }
                        }) {
                            Image(systemName: "plus.circle")
                        }
                        .accessibilityIdentifier("CategoryAddButton")
                    }
                }
                .alert(item: $alertItem) { item in
                    switch item {
                    case .maxCategories:
                        return Alert(
                            title: Text(Localization.errors.addMaxNumberOfCategoriesErrorTitle),
                            message: Text(Localization.errors.addMaxNumberOfCategoriesMessage),
                            dismissButton: .default(Text(Localization.labels.ok))
                        )
                    case .deletionFailed:
                        return Alert(
                            title: Text(Localization.errors.deletionErrorTitle),
                            message: Text(Localization.errors.deletionErrorCategoryMessage),
                            dismissButton: .default(Text(Localization.labels.ok))
                        )
                    }
                }
                .toolbarBackground(Color.clear, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .navigationBarTitleDisplayMode(.inline)
            }
            .accessibilityIdentifier("CategoryListContainer")
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        categoryViewModel.moveCategory(from: source, to: destination)
    }
}

enum CategoryAlertItem: Identifiable {
    case maxCategories, deletionFailed
    var id: Self { self }
}
