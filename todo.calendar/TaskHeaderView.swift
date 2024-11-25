//
//  TaskHeaderView.swift
//  todo.calendar
//
//  Created by Lit Wa Yuen on 11/24/24.
//

import SwiftUI

struct TaskHeaderView: View {
    @Binding var task: Task

    var body: some View {
        Section {
            TextField("Title", text: $task.title)
            DatePicker("Date", selection: $task.date, displayedComponents: .date)
        }
    }
}
