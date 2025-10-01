//
//  Views/ContentView.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//

import SwiftUI
import CoreData

struct ContentView: View {

    @State private var showRandomTodoView = true
    
    @State private var selectedTab: Int = 1
    
    var randomTodoDisplayDuration: TimeInterval = {
        if ProcessInfo.processInfo.arguments.contains("--UITestMode") {
            return 5
        }
        return 3
    }()

    var body: some View {
        ZStack {
            
            TabView(selection: $selectedTab) {
                TodoListView()
                    .tabItem {
                        Label(Localization.labels.allTodosNav, systemImage: "list.bullet")
                    }.tag(0)
                    .accessibilityIdentifier("AllTodosTab")
                TodaysListView()
                    .tabItem {
                        Label(Localization.labels.todayNav, systemImage: "calendar")
                    }.tag(1)
                    .accessibilityIdentifier("TodayTab")
                RecurringTaskListView()
                    .tabItem {
                        Label(Localization.labels.recurringTasksNav, systemImage: "checklist")
                    }.tag(2)
                    .accessibilityIdentifier("RecurringTaskTab")
            }
            
            if showRandomTodoView {
                RandomTodoView(isPresented: $showRandomTodoView)
                    .transition(.opacity)
                    .animation(.easeInOut, value: showRandomTodoView)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + randomTodoDisplayDuration) {
                withAnimation {
                    showRandomTodoView = false
                }
            }
        }
    }

}
