//
//  ReminderModalView.swift
//  todo.calendar
//
//  Created by Lit Wa Yuen on 12/1/24.
//

import SwiftUI

struct ReminderModalView: View {
    @Binding var isReminderSet: Bool
    @Binding var reminderDate: Date? // Optional Date
    @Binding var isNewTask: Bool
    var onSave: () -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Reminder Date and Time")) {
                    DatePicker(
                        "Select Reminder",
                        selection: Binding(
                            get: { reminderDate ?? Date() },
                            set: { reminderDate = $0 }
                        ),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())
                }
            }
            .navigationBarTitle("Set Reminder", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    isReminderSet = true
                    if !isNewTask {
                        onSave()
                    }
                    dismiss()
                }
            )
        }
    }
}
