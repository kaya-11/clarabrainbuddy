//
//  Views/ContentView.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var todoViewModel = TodoViewModel()
    @StateObject private var taskViewModel = TaskViewModel()
    
    @State private var selectedTab: Int = 1 // Set the default tab to the middle one
    
    let allTodosNavString = NSLocalizedString("navigation.alltodos", comment: "Navigation All Todos")
    let todayNavString = NSLocalizedString("navigation.today", comment: "Navigation Today")
    let recurringTasksNavString = NSLocalizedString("navigation.recurringtasks", comment: "Navigation Recurring Tasks")

    var body: some View {
        TabView(selection: $selectedTab) {
            TodoListView(todoViewModel: todoViewModel)
                .tabItem {
                    Label(allTodosNavString, systemImage: "list.bullet")
                }.tag(0)
            TodaysListView(todoViewModel: todoViewModel, taskViewModel: taskViewModel)
                .tabItem {
                    Label(todayNavString, systemImage: "calendar")
                }.tag(1)
            RecurringTaskListView(taskViewModel: taskViewModel)
                .tabItem {
                    Label(recurringTasksNavString, systemImage: "checklist")
                }.tag(2)
        }
    }

}
