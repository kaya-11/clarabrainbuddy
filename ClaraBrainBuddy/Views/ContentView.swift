//
//  Views/ContentView.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TodoViewModel()
    @StateObject private var taskViewModel = TaskViewModel()

    var body: some View {
        TabView {
            TodoListView(todoViewModel: viewModel)
                .tabItem {
                    Label("All Todos", systemImage: "list.bullet")
                }
            TodaysListView(todoViewModel: viewModel)
                .tabItem {
                    Label("Today's Todos", systemImage: "calendar")
                }
            RecurringTaskListView(taskViewModel: taskViewModel)
                .tabItem {
                    Label("Recurring Tasks", systemImage: "checklist")
                }
        }
    }
}
