//
//  AddTaskModalView.swift
//  todo.calendar
//
//  Created by Lit Wa Yuen on 11/21/24.
//
import SwiftUI

struct AddTaskModalView: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var selectedDate: Date? = nil
    @State private var taskTitle: String = ""
    @State private var taskDescription: String = ""
    @Environment(\.presentationMode) private var presentationMode // For dismissing the modal
    @State private var showAlert = false
    @State private var alertMessage = ""
    @FocusState private var isTaskTitleFocused: Bool // Focus state for the text field


    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Title")) {
                    TextField("Enter task title", text: $taskTitle)
                        .focused($isTaskTitleFocused) // Bind the focus state
                }
                Section(header: Text("Task Description")) {
                    TextField("Enter task description", text: $taskDescription)
                }
                Section(header: Text("Task Date")) {
                    DatePickerButtonView(selectedDate: $selectedDate)
                }
                Section {
                    Button(action: {
                        addTask()
                    }) {
                        Text("Save Task")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(taskTitle.isEmpty) // Disable if title is empty
                }
            }
            .onAppear {
                isTaskTitleFocused = true // Automatically focus when the modal appears
            }
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func addTask() {
        viewModel.addTask(title: taskTitle, description: taskDescription, date: selectedDate) { result in
            switch result {
            case .success:
                // Dismiss the modal on success
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                // Show an alert on failure
                alertMessage = "Failed to add task: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
}
