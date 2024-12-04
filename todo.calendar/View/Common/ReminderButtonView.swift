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
        
        Button(action: {
            showReminderModal = true
        }) {
            HStack {
                Image(systemName: "clock") // Replace with your desired image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                
                Text(getText()) // Replace with your text
                
            }
            .padding(.leading)
            .padding(.trailing)
            .foregroundColor(isReminderSet ? .black : .gray)
            .background(
                RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                )
                .stroke(isReminderSet ? .black : .gray, lineWidth: 2)
            )
        }
        .sheet(isPresented: $showReminderModal) {
            ReminderModalView(isReminderSet: $isReminderSet, reminderDate: $reminderDate, isNewTask: $isNewTask, onSave: setReminder)
        }
        .alert(isPresented: $showPermissionAlert) {
            Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func getText() -> String {
        return isReminderSet ? formattedDate(reminderDate!) : "Reminders"
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
