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
    
    @State private var showDeletionFailedAlert = false
    
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
        NavigationView {
            VStack {
                List {
                    ForEach(filteredCategories, id: \.id) { category in
                        HStack {
                            ColorCircleView(hex: category.color, size: 20)
                            Text(category.name)
                                .foregroundColor(Color.theme.primary)
                            Spacer()
                            if category.isDefault {
                                Image(systemName: "star.fill")
                                    .foregroundColor(Color.theme.accent)
                                    .font(Font.app.listItem)
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                if (category.todos.isEmpty) {
                                    categoryViewModel.deleteCategory(category)
                                } else {
                                    showDeletionFailedAlert = true
                                }
                            } label: {
                                Label(Localization.labels.delete, systemImage: "trash")
                            }
                            .tint(.red)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                selectedCategory = category
                            } label: {
                                Label(Localization.labels.edit, systemImage: "pencil")
                            }
                            .tint(.green)
                        }
                        .listRowBackground(Color.theme.listBackground)
                    }
                    .onMove(perform: move)
                }
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                .sheet(item: $selectedCategory) { category in
                    CategoryFormView(categoryViewModel: categoryViewModel, existingCategory: category).accessibilityIdentifier("TodoFormView")
                }
                .sheet(isPresented: $showingAddCategory) {
                    CategoryFormView(categoryViewModel: categoryViewModel, existingCategory: nil)
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
                        .accessibilityIdentifier("CategoryListBackButton")
                    }
                    ToolbarItem(placement: .principal) {
                        Text(Localization.labels.categories)
                            .foregroundColor(Color.theme.primary)
                            .font(Font.app.title)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingAddCategory = true
                        }) {
                            Image(systemName: "plus.circle")
                        }
                    }
                }
                .alert(isPresented: $showDeletionFailedAlert) {
                    Alert(
                        title: Text(Localization.errors.deletionErrorTitle),
                        message: Text(Localization.errors.deletionErrorCategoryMessage),
                        dismissButton: .default(Text(Localization.labels.ok))
                    )
                }
                .navigationBarTitleDisplayMode(.inline)
            }
            .accessibilityIdentifier("CategoryListContainer")
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        categoryViewModel.moveCategory(from: source, to: destination)
    }
}
