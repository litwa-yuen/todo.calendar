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

    var body: some View {
        Section {
            TextField("Title", text: $task.title)
                .foregroundColor(.primary)
            DatePickerButtonView(selectedDate: $selectedDate)
          
        }
        .onAppear {
            selectedDate = task.date
        }
    }
}
