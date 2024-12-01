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
    @State private var showPermissionAlert = false
    @State private var alertMessage = ""

    var body: some View {
        Button(action: {
            setReminder()
        }) {
            Text("Set Reminder")
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .foregroundColor(.white)
                .background(task.date == nil ? Color.gray : Color.blue)
                .cornerRadius(8)
        }
        .disabled(task.date == nil) // Disable button if date is not set
        .alert(isPresented: $showPermissionAlert) {
            Alert(title: Text("Permission Required"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func setReminder() {
        guard let dueDate = task.date else {
            alertMessage = "Please set a due date before setting a reminder."
            showPermissionAlert = true
            return
        }

        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                DispatchQueue.main.async {
                    alertMessage = "Failed to request notification permission: \(error.localizedDescription)"
                    showPermissionAlert = true
                }
                return
            }

            if granted {
                scheduleNotification(for: dueDate)
            } else {
                DispatchQueue.main.async {
                    alertMessage = "Please enable notifications in your settings to use reminders."
                    showPermissionAlert = true
                }
            }
        }
    }

    private func scheduleNotification(for date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = "Reminder for task: \(task.title)"
        content.sound = .default

        // Create the trigger
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        // Create the request
        let request = UNNotificationRequest(identifier: task.id ?? UUID().uuidString, content: content, trigger: trigger)

        // Add the request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    alertMessage = "Failed to schedule notification: \(error.localizedDescription)"
                    showPermissionAlert = true
                } else {
                    alertMessage = "Reminder successfully set for \(task.title)."
                    showPermissionAlert = true
                }
            }
        }
    }
}
