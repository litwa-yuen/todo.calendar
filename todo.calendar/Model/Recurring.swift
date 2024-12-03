//
//  Recurring.swift
//  todo.calendar
//
//  Created by Lit Wa Yuen on 12/1/24.
//

import Foundation


enum RecurrenceType: String, Codable, CaseIterable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    case custom = "Custom"
}

enum DayOfWeek: String, Codable, CaseIterable {
    case sunday = "Sunday"
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
}


struct Recurring: Codable {
    var recurrenceType: RecurrenceType
    var startDate: Date?
    var endDate: Date?
    var interval: Int? // For custom intervals (e.g., every 2 days)
    var selectedDays: [DayOfWeek]? // For weekly recurrence
    
    init() {
        recurrenceType = .none
    }

}
