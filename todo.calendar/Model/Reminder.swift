//
//  Reminder.swift
//  todo.calendar
//
//  Created by Lit Wa Yuen on 12/1/24.
//

import Foundation
import FirebaseFirestore

struct Reminder: Codable {
    var isReminderSet: Bool
    var date: Date?
    
    init() {
        isReminderSet = false
        date = nil
    }
    
    var dictionary: [String: Any] {
        return [
            "isReminderSet": isReminderSet,
            "date": date
        ]
    }

}
