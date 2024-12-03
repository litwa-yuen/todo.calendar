//
//  ReminderButtonView.swift
//  todo.calendar
//
//  Created by Lit Wa Yuen on 12/1/24.
//
import SwiftUI
import UserNotifications

struct ReminderButtonView: View {
    @Binding var task: Task
    @State private var showReminderModal = false
    @State private var showPermissionAlert = false
    @State private var alertMessage = ""
    @Binding var isNewTask: Bool
    @Binding var isReminderSet: Bool
    @Binding var reminderDate: Date?

    var body: some View {
        VStack {
            HStack {
                if isReminderSet {
                    Image(systemName: "clock")
                        .foregroundColor(.blue)
                    Text("Reminder: \(formattedDate(reminderDate!))")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                } else {
                    Text("No Reminder Set")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
            }
            .padding(.bottom, 8)

            Button(action: {
                showReminderModal = true
            }) {
                Text("Set Reminder")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .sheet(isPresented: $showReminderModal) {
            ReminderModalView(isReminderSet: $isReminderSet, reminderDate: $reminderDate, isNewTask: $isNewTask, onSave: setReminder)
        }
        .alert(isPresented: $showPermissionAlert) {
            Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func setReminder() {
        guard let dueDate = reminderDate else {
            alertMessage = "Please set a due date before setting a reminder."
            showPermissionAlert = true
            return
        }

        NotificationManager.shared.requestNotificationPermission { granted, error in
            if let error = error {
                alertMessage = "Failed to request notification permission: \(error.localizedDescription)"
                showPermissionAlert = true
                return
            }

            if granted {
                NotificationManager.shared.scheduleNotification(taskTitle: task.title, taskId: task.id ?? UUID().uuidString, dueDate: dueDate) { error in
                    if let error = error {
                        alertMessage = "Failed to schedule notification: \(error.localizedDescription)"
                    } else {
                        alertMessage = "Reminder successfully set for \(task.title)."
                    }
                    showPermissionAlert = true
                }
            } else {
                alertMessage = "Please enable notifications in your settings to use reminders."
                showPermissionAlert = true
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}