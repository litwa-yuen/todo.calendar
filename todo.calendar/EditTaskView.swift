//
//  EditTaskView.swift
//  todo.calendar
//
//  Created by Lit Wa Yuen on 11/23/24.
//

import SwiftUI

struct EditTaskView: View {
    @Binding var task: Task // The task being edited
    @ObservedObject var viewModel: TaskViewModel
    @Environment(\.dismiss) var dismiss // To close the modal

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $task.title)
                    
                    DatePicker("Date", selection: $task.date, displayedComponents: .date)
                }
            }
            .navigationTitle("Edit Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Delete") {
                        viewModel.deleteTask(taskId: $task.id!)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTask()
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveTask() {
        viewModel.updateTask() // Update the task in the view model or Firestore
    }
}
