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
    @State private var isReminderSet: Bool = false
    @State private var reminderDate: Date? = nil

    var body: some View {
        Section {
            TextField("Title", text: $task.title)
                .foregroundColor(.primary)
            DatePickerButtonView(task: $task, viewModel: viewModel, isNewTask: .constant(false), selectedDate: $selectedDate)
            ReminderButtonView(task: $task, isNewTask: .constant(false), isReminderSet: $isReminderSet, reminderDate: $reminderDate)
          
        }
        .onAppear {
            selectedDate = task.date
        }
    }
}
