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
    
    private let eventProvider: EventProvider
    
    init(todoViewModel: TodoViewModel, eventProvider: EventProvider) {
        self.todoViewModel = todoViewModel
        self.eventProvider = eventProvider
    }

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(events, id: \.self) { event in
                        
                        let eventAlreadyExistsAsTodo = todoViewModel.eventAlreadyExistsAsTodo(event)
                        let startDate: Date = event.startDate
                        let endDate: Date = event.endDate
                        
                        VStack(alignment: .leading) {
                            HStack {
                                if eventAlreadyExistsAsTodo {
                                    Text("🌀🐿️")
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
                                    let title: String = event.title
                                    let details: String = event.hasNotes ? event.notes ?? "" : ""
                                    let estimatedTime: Int64 = Int64((endDate.timeIntervalSince(startDate)) / 60)
                                    todoViewModel.addNewTodoForToday(title: title, details: details, estimatedTime: estimatedTime)
                                } label: {
                                    Label(Localization.labels.addTodoToday, systemImage: "calendar")
                                }
                                .tint(.blue)
                                .accessibilityIdentifier("AddEventAsTodayTodoButton")
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
                    .accessibilityIdentifier("CancelTodaysEventsButton")
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
        .onAppear () {
            fetchEvents()
        }
    }
    
    private func fetchEvents() {
        eventProvider.fetchTodayEvents { fetchedEvents in
            self.events = fetchedEvents
        }
    }
}

