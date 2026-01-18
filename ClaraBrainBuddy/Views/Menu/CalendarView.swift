//
//  Views/Menu/CalendarView.swift
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
    
    private let onlyToday: Bool
    
    init(todoViewModel: TodoViewModel, eventProvider: EventProvider, onlyToday: Bool = false) {
        self.todoViewModel = todoViewModel
        self.eventProvider = eventProvider
        self.onlyToday = onlyToday
    }

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(events, id: \.self) { event in
                        
                        let startDate: Date = event.startDate
                        let endDate: Date = event.endDate
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text(event.title)
                                    .font(Font.app.listItem)
                            }
                            let formattedStartDate = DateFormatter.localizedString(from: startDate, dateStyle: .short, timeStyle: .short)
                            let formattedEndDate = DateFormatter.localizedString(from: endDate, dateStyle: .short, timeStyle: .short)
                            Text("\(formattedStartDate) - \(formattedEndDate)")
                                .font(Font.app.tiny)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                let title: String = event.title
                                let details: String = event.hasNotes ? event.notes ?? "" : ""
                                let estimatedTime: Int64? = event.isAllDay
                                                ? nil
                                                : Int64((endDate.timeIntervalSince(startDate)) / 60)
                                
                                todoViewModel.addNewTodoForToday(title: title, details: details, estimatedTime: estimatedTime)
                                
                                fetchEvents()
                            } label: {
                                Label(Localization.labels.addTodoToday, systemImage: "calendar")
                            }
                            .tint(.blue)
                            .accessibilityIdentifier("AddEventAsTodayTodoButton")
                            
                        }
                        .foregroundColor(Color.theme.listText)
                        .listRowBackground(Color.theme.listBackground)
                        .font(Font.app.listItem)
                    }
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .appTheme()
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
                    let label : String = onlyToday ? Localization.labels.todaysEvents : Localization.labels.upcomingEvents;
                    Text(label)
                        .foregroundColor(Color.theme.primary)
                        .font(Font.app.header)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear () {
            fetchEvents()
        }
    }
    
    private func fetchEvents() {
        if (onlyToday) {
            eventProvider.fetchTodayEvents { fetchedEvents in
                self.events = fetchedEvents.filter { !todoViewModel.eventAlreadyExistsAsTodo($0) }
            }
        } else {
            eventProvider.fetchTodayAndTomorrowsEvents { fetchedEvents in
                self.events = fetchedEvents.filter { !todoViewModel.eventAlreadyExistsAsTodo($0) }
            }
        }
    }
}

