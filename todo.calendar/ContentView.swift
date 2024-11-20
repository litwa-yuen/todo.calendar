//
//  ContentView.swift
//  todo.calendar
//
//  Created by Lit Wa Yuen on 11/16/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var viewModel = TaskViewModel()
    @State private var selectedDate = Date()
    @State var selectedTab = 0

    var body: some View {
        TabView (selection: $selectedTab) {
            
            TaskListView(viewModel: viewModel, selectedDate: Date())
                .background(Color(.systemGroupedBackground))
                .imageScale(.large)
                .foregroundStyle(.tint)
                .tabItem {

                    Image(systemName: "pencil")
                    Text("Today")
                }
                .tag(0)
                .onAppear {
                    viewModel.fetchTasks()
                }
           
            CalendarListView(viewModel: viewModel)
                .background(Color(.systemGroupedBackground))
                .imageScale(.large)
                .foregroundStyle(.tint)
                .tabItem {

                    Image(systemName: "pencil")
                    Text("Calendar")
                }
                .tag(1)
                .onAppear {
                    viewModel.fetchTasks()
                }
        }
      
    }
}

