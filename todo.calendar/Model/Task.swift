//
//  Task.swift
//  todo.calendar
//
//  Created by Lit Wa Yuen on 11/16/24.
//

import Foundation
import FirebaseFirestore



struct Task: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var date: Date?
    var isDone: Bool
    var reminder: Reminder
   // var recurring: Recurring
    var subtasks: [Subtask] // New property for subtasks

    var dictionary: [String: Any] {
        return [
            "id": id,
            "title": title,
            "description": description,
            "date": date,
            "isDone": isDone,
            "reminder": reminder.dictionary,
        //    "recurring": recurring,
            "subtasks": subtasks.map { $0.dictionary }
        ]
    }
}
