//
//  TaskListView.swift
//  todo.calendar
//
//  Created by Lit Wa Yuen on 11/16/24.
//

import SwiftUI

struct TaskListView: View {
    @ObservedObject var viewModel: TaskViewModel
    var selectedDate: Date
        
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.tasks.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) { task in
                    TaskRowView(task: task, viewModel: viewModel)
                }
            }
            .navigationTitle("Today")
        }
        
      
    }
}
