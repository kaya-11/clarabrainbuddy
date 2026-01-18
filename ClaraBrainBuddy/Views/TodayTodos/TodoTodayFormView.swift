import SwiftUI

struct TodoTodayFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var todoViewModel: TodoViewModel
    @ObservedObject var categoriesViewModel: CategoryViewModel

    @State private var title: String
    @State private var details: String
    @State private var dueDate: Date
    @State private var estimatedTime: Int64?
    @State private var energyImpact: Int64?
    @State private var isDone: Bool
    @State private var category: Category?

    @State private var showErrorTitle: Bool = false
    @State private var errorMessageTitle: String = ""
    @State private var showErrorDetails: Bool = false
    @State private var errorMessageDetails: String = ""

    init(todoViewModel: TodoViewModel) {
        self.todoViewModel = todoViewModel
        self.categoriesViewModel = CategoryViewModel.shared
        
        _title = State(initialValue: "" )
        _details = State(initialValue: "")
        _dueDate = State(initialValue: Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date())
        _estimatedTime = State(initialValue: nil)
        _energyImpact = State(initialValue: 0)
        _isDone = State(initialValue: false)
        _category = State(initialValue: nil)
    }

    func validateTitle(_ name: String) {
        if name.count > TodoViewModel.TITLE_MAX_LENGTH {
            showErrorTitle = true
            errorMessageTitle = Localization.errors.todoTitleLengthError
        } else {
            showErrorTitle = false
            errorMessageTitle = ""
        }
    }

    func validateDetails(_ name: String) {
        if name.count > TodoViewModel.DETAILS_MAX_LENGTH {
            showErrorDetails = true
            errorMessageDetails = Localization.errors.todoDetailsLengthError
        } else {
            showErrorDetails = false
            errorMessageDetails = ""
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(Localization.labels.titleForm)) {
                    TextField(Localization.labels.titleFormTooltip, text: $title)
                        .foregroundColor(Color.theme.primary)
                        .background(showErrorTitle ? Color.red.opacity(0.2) : nil)
                        .onChange(of: title) {
                            validateTitle(title)
                        }
                    if showErrorTitle {
                        Text(errorMessageTitle)
                            .foregroundColor(.red)
                            .font(Font.app.small)
                    }
                }
                .accessibilityIdentifier("TodayTodoFormTitleTextField")
                .sectionSytle()
                
                Section(header: Text(Localization.labels.details)) {
                    TextEditor(text: $details)
                        .frame(height: 120)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray.opacity(0.3)))
                        .background(showErrorDetails ? Color.red.opacity(0.2) : nil)
                        .onChange(of: details) {
                            validateDetails(details)
                        }
                    if showErrorDetails {
                        Text(errorMessageDetails)
                            .foregroundColor(.red)
                            .font(Font.app.small)
                    }
                }
                .sectionSytle()
                
                if (categoriesViewModel.hasCategories()) {
                    Section(header: Text(Localization.labels.category)) {
                        CategoryPickerView(selectedCategory: $category)
                            .accessibilityIdentifier("TodayTodoFormCategoryPicker")
                    }
                    .sectionSytle()
                }
                
                Section(header: Text(Localization.labels.estimatedTimeForm)) {
                    TextField(Localization.labels.estimatedTimeTooltip, value: $estimatedTime, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .foregroundColor(Color.theme.primary)
                }
                .sectionSytle()
                
                Section(header: Text(Localization.labels.energyImpact)) {
                    HStack {
                        Battery50Icon()
                        Slider(value: Binding(
                            get: { Double(energyImpact ?? 0) },
                            set: { energyImpact = Int64($0) }
                        ), in: -1...1, step: 1)
                        Battery100Icon()
                    }
                }
                .sectionSytle()
                
                Button(action: {
                    todoViewModel.addNewTodoForToday(title: title, details: details, estimatedTime: estimatedTime, energyImpact: energyImpact ?? 0, category: category)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text(Localization.labels.saveAddTodo)
                }
                .buttonStyle()
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || showErrorTitle || showErrorDetails)
                .accessibilityLabel("TodaysTodoFormSaveButton")
                
            }
            .appTheme()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(Localization.labels.addTodoToday)
                        .foregroundColor(Color.theme.primary)
                        .font(Font.app.header)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
