//
//  AddTaskModalView.swift
//  todo.calendar
//
//  Created by Lit Wa Yuen on 11/21/24.
//
import SwiftUI

struct AddTaskModalView: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var selectedDate: Date? = Date()
    @State private var taskTitle: String = ""
    @State private var taskDescription: String = ""
    @Environment(\.presentationMode) private var presentationMode // For dismissing the modal
    @State private var showAlert = false
    @State private var alertMessage = ""
    @FocusState private var isTaskTitleFocused: Bool // Focus state for the text field
    @State private var fakeTask = Task(
        id: UUID().uuidString,
        title: "Fake Task",
        description: "Fake Task Description",
        date: Date(),
        isDone: false,
        subtasks: []
    )


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
                    DatePickerButtonView(task: $fakeTask, viewModel: viewModel, isNewTask: .constant(true), selectedDate: $selectedDate)
                }
                Section(header: Text("Set Reminder")) {
                    ReminderButtonView(task: $fakeTask)
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
