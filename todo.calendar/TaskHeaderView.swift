//
//  TaskHeaderView.swift
//  todo.calendar
//
//  Created by Lit Wa Yuen on 11/24/24.
//

import SwiftUI

struct TaskHeaderView: View {
    @Binding var task: Task
    @State private var selectedDate: Date? = nil
    @ObservedObject var viewModel: TaskViewModel

    var body: some View {
        Section {
            TextField("Title", text: $task.title)
                .foregroundColor(.primary)
            DatePickerButtonView(task: $task, viewModel: viewModel, isNewTask: .constant(false), selectedDate: $selectedDate)
          
        }
        .onAppear {
            selectedDate = task.date
        }
    }
}
