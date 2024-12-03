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
    @State private var recurring: Recurring = Recurring.init()
    @Environment(\.presentationMode) private var presentationMode // For dismissing the modal
    @State private var showAlert = false
    @State private var alertMessage = ""
    @FocusState private var isTaskTitleFocused: Bool // Focus state for the text field
    @State private var isReminderSet: Bool = false
    @State private var reminderDate: Date? = Date()


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
                    DatePickerButtonView(task: bindTask(), viewModel: viewModel, isNewTask: .constant(true), selectedDate: $selectedDate)
                }
                Section(header: Text("Set Reminder")) {
                    ReminderButtonView(task: bindTask(), isNewTask: .constant(true), isReminderSet: $isReminderSet, reminderDate: $reminderDate)
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
    
    private func bindTask() -> Binding<Task> {
        return .constant(Task(title: taskTitle, description: taskDescription, date: selectedDate, isDone: false, reminder: Reminder(), /*recurring: recurring,*/ subtasks: []))
    }
    
    private func addTask() {
        var reminder = Reminder()
        reminder.date = reminderDate
        reminder.isReminderSet = isReminderSet
        let newTaskId = viewModel.getNewTaskId()
        if isReminderSet {
            setReminder(taskId: newTaskId)
        }
        viewModel.addTask(taskId: newTaskId, title: taskTitle, description: taskDescription, reminder: reminder, /*recurring: recurring,*/ date: selectedDate) { result in
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
    
    private func setReminder(taskId: String) {
        guard let dueDate = reminderDate else {
            alertMessage = "Please set a due date before setting a reminder."
            showAlert = true
            return
        }

        NotificationManager.shared.requestNotificationPermission { granted, error in
            if let error = error {
                alertMessage = "Failed to request notification permission: \(error.localizedDescription)"
                showAlert = true
                return
            }

            if granted {
                NotificationManager.shared.scheduleNotification(taskTitle: taskTitle, taskId: taskId, dueDate: dueDate) { error in
                    if let error = error {
                        alertMessage = "Failed to schedule notification: \(error.localizedDescription)"
                        showAlert = true
                    } 
                }
            } else {
                alertMessage = "Please enable notifications in your settings to use reminders."
                showAlert = true
            }
        }
    }
}
