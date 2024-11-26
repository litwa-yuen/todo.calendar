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

    @State private var isSubtaskModalPresented = false // Controls the subtask modal visibility

    var body: some View {
        NavigationView {
            Form {
                TaskHeaderView(task: $task)
                TaskBodyView(viewModel: viewModel, isSubtaskModalPresented: $isSubtaskModalPresented)
            }
            .padding(.top)
            .ignoresSafeArea()
            .toolbar {
                // Cancel Button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                // Delete Button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Delete") {
                        viewModel.deleteTask(taskId: task.id!)
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
                // Save Button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTask()
                        dismiss()
                    }
                }
            }
        }
   
        .sheet(isPresented: $isSubtaskModalPresented) {
            AddSubtaskModalView(viewModel: viewModel)
                .presentationDetents([.fraction(0.1)]) // Show the modal in half-screen size
        }
    }

    private func saveTask() {
        viewModel.updateTask() // Update the task in the view model or Firestore
    }
}
