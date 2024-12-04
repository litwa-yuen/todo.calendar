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
            VStack {
                
                TextField("Task Name", text: $taskTitle)
                    .font(Font.headline)
                    .focused($isTaskTitleFocused) // Bind the focus state
                
                
                TextField("Description", text: $taskDescription)
                    .font(Font.subheadline)
                    .padding(.bottom)
                
                HStack {
                    DatePickerButtonView(task: bindTask(), viewModel: viewModel, isNewTask: .constant(true), selectedDate: $selectedDate)
                    
                    ReminderButtonView(task: bindTask(), isNewTask: .constant(true), isReminderSet: $isReminderSet, reminderDate: $reminderDate)
                    
                    Spacer()
                }
                .padding(.bottom)
                
                
            }
            .onAppear {
                isTaskTitleFocused = true // Automatically focus when the modal appears
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer() // Push the button to the right
                    Button("Save") {
                        addTask()
                    }
                    .disabled(taskTitle.isEmpty) // Disable if title is empty
                }
            }
            .padding(.top)
            .padding(.leading)
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
