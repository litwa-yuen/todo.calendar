//
//  TaskBodyView.swift
//  todo.calendar
//
//  Created by Lit Wa Yuen on 11/24/24.
//

import SwiftUI

struct TaskBodyView: View {
    @ObservedObject var viewModel: TaskViewModel
    @Binding var isSubtaskModalPresented: Bool

    var body: some View {
        Section(header: Text("Subtasks")) {
            if viewModel.subtasks.isEmpty {
                Text("No subtasks added yet.")
                    .foregroundColor(.gray)
            } else {
                ForEach(viewModel.subtasks) { subtask in
                    SubtaskRowView(subtask: subtask, viewModel: viewModel)
                }
            }
        }

        Section {
            Button(action: {
                isSubtaskModalPresented = true // Open the subtask modal
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Add Subtask")
                }
                .foregroundColor(.blue)
            }
        }
        .onAppear {
            viewModel.subscribeSubtask()
        }
        .onDisappear {
            viewModel.unsubscribeSubtask()
        }
    }
}
