//
//  TaskListView.swift
//  todo.calendar
//
//  Created by Lit Wa Yuen on 11/16/24.
//

import SwiftUI

struct TaskListView: View {
    @ObservedObject var viewModel: TaskViewModel
    let selectedDate: Date?
    let title: String
        
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.tasks) { task in
                    TaskRowView(task: task, viewModel: viewModel)
                }
            }
            .navigationTitle(title)
        }
        .onAppear() {
            viewModel.unsubscribe()
            viewModel.subscribe(selectedDate: selectedDate, isNext7Days: false)
        }      
    }
}
