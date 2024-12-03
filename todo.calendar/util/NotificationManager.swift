//
//  NotificationManager.swift
//  todo.calendar
//
//  Created by Lit Wa Yuen on 12/1/24.
//

import Foundation
import UserNotifications

class NotificationManager {
    
    static let shared = NotificationManager()

    private init() {}
    

    /// Requests notification permission from the user
    func requestNotificationPermission(completion: @escaping (Bool, Error?) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completion(granted, error)
            }
        }
    }

    /// Schedules a notification for a specific date
    func scheduleNotification(taskTitle: String, taskId: String, dueDate: Date, completion: @escaping (Error?) -> Void) {
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = "Reminder for task: \(taskTitle)"
        content.sound = .default

        // Create the trigger
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        // Create the request
        let request = UNNotificationRequest(identifier: taskId, content: content, trigger: trigger)

        // Add the request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
}
