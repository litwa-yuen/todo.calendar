//
//  AddSubtaskModalView.swift
//  todo.calendar
//
//  Created by Lit Wa Yuen on 11/24/24.
//

import SwiftUI

struct AddSubtaskModalView: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var taskTitle: String = ""
    @Environment(\.presentationMode) private var presentationMode // For dismissing the modal
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Subtask Title")) {
                    TextField("Enter subtask title", text: $taskTitle)
                }
                Section {
                    Button(action: {
                        addSubtask()
                    }) {
                        Text("Save Subtask")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(taskTitle.isEmpty) // Disable if title is empty
                }
            }
            .navigationTitle("Add Subtask")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func addSubtask() {
        viewModel.addSubtask(subtaskTitle: taskTitle) { result in
            switch result {
            case .success:
                // Dismiss the modal on success
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                alertMessage = "Failed to add task: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
}
