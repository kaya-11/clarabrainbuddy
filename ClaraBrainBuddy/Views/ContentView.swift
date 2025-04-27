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
    
    @State private var showRandomTodoView = true
    
    @State private var selectedTab: Int = 1

    var body: some View {
        ZStack {
            
            TabView(selection: $selectedTab) {
                TodoListView(todoViewModel: todoViewModel)
                    .tabItem {
                        Label(Localization.labels.allTodosNav, systemImage: "list.bullet")
                    }.tag(0)
                TodaysListView(todoViewModel: todoViewModel, taskViewModel: taskViewModel)
                    .tabItem {
                        Label(Localization.labels.todayNav, systemImage: "calendar")
                    }.tag(1)
                RecurringTaskListView(taskViewModel: taskViewModel)
                    .tabItem {
                        Label(Localization.labels.recurringTasksNav, systemImage: "checklist")
                    }.tag(2)
            }
            
            if showRandomTodoView {
                RandomTodoView(todoViewModel: todoViewModel, isPresented: $showRandomTodoView)
                    .transition(.opacity)
                    .animation(.easeInOut, value: showRandomTodoView)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    showRandomTodoView = false
                }
            }
        }
    }

}
