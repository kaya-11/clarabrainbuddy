//
//  Views/CalendarView.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 01.06.25.
//

import SwiftUI
import EventKit

struct CalendarView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var todoViewModel: TodoViewModel
    
    @State private var showErrorMessage = false
   
    @State private var events: [EKEvent] = []
    
    init(todoViewModel: TodoViewModel) {
        self.todoViewModel = todoViewModel
    }

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(events, id: \.self) { event in
                        
                        let eventAlreadyExistsAsTodo = todoViewModel.eventAlreadyExistsAsTodo(event)
                        let startDate: Date = event.startDate ?? Date()
                        let endDate: Date = event.endDate ?? Date().addingTimeInterval(60 * 60 * 24)
                        
                        VStack(alignment: .leading) {
                            HStack {
                                if eventAlreadyExistsAsTodo {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(Color.theme.blue)
                                }
                                Text(event.title)
                                    .font(Font.app.listItem)
                            }
                            let formattedStartDate = DateFormatter.localizedString(from: startDate, dateStyle: .short, timeStyle: .short)
                            let formattedEndDate = DateFormatter.localizedString(from: endDate, dateStyle: .short, timeStyle: .short)
                            Text("\(formattedStartDate) - \(formattedEndDate)")
                                .font(Font.app.tiny)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            if !eventAlreadyExistsAsTodo {
                                Button {
                                    let title: String = event.title ?? ""
                                    let details: String = event.hasNotes ? event.notes ?? "" : ""
                                    let estimatedTime: Int = Int((endDate.timeIntervalSince(startDate)) / 60)
                                    todoViewModel.addNewTodoForToday(title: title, details: details, estimatedTime: estimatedTime)
                                } label: {
                                    Label(Localization.labels.addTodoToday, systemImage: "calendar")
                                }
                                .tint(.blue)
                            }
                            
                        }
                        .foregroundColor(StyleUtils.getTextColorForEvent(eventIsInTodos: todoViewModel.eventAlreadyExistsAsTodo(event)))
                        .listRowBackground(Color.theme.listBackground)
                        .font(Font.app.listItem)
                    }
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .backgroundStyle()
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(Localization.labels.back)
                            .font(Font.app.button)
                    }
                }
                ToolbarItemGroup(placement: .principal) {
                    Text("Today's Events")
                        .foregroundColor(Color.theme.primary)
                        .font(Font.app.title)
                }
            }
            .toolbarBackground(Color.theme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onAppear() {
            fetchEvents()
        }
    }
    
    private func fetchEvents() {
        let eventStore = EKEventStore()
        eventStore.requestFullAccessToEvents { (granted, error) in
            if granted {
                let calendar = Calendar.current
                let startDate = calendar.startOfDay(for: Date())
                let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!

                let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
                let todayEvents = eventStore.events(matching: predicate)

                DispatchQueue.main.async {
                    self.events = todayEvents
                }
            }
        }
    }
}

