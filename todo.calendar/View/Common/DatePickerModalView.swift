//
//  DatePickerModalView.swift
//  todo.calendar
//
//  Created by Lit Wa Yuen on 11/27/24.
//

import SwiftUI

struct DatePickerModalView: View {
    @Binding var task: Task?
    @ObservedObject var viewModel: TaskViewModel
    @Environment(\.dismiss) var dismiss // To close the modal
    @State private var tempDate: Date = Date() // Temporary date for selection
    @Binding public var isNewTask: Bool
    @Binding public var selectedDate: Date?
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    // Date Picker Section
                    Section(header: Text("Select a Date")) {
                                   DatePicker("Due Date", selection: Binding(
                                       get: { selectedDate ?? tempDate },
                                       set: { selectedDate = $0 }
                                   ), displayedComponents: .date)
                               }
                    
                    // No Due Date Option
                    Section {
                        Button("No Due Date") {
                            selectedDate = nil
                            if !isNewTask {
                                task?.date = nil
                                updateTaskDate(taskId: task?.id! ?? "", date: nil)
                            }
                            dismiss()
                        }
                        .foregroundColor(.red)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Pick a Date")
            .toolbar {
                // Cancel Button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                // Save Button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if isNewTask {
                            selectedDate = tempDate
                        } else {
                            task?.date = tempDate
                            selectedDate = tempDate
                            updateTaskDate(taskId: task?.id! ?? "", date: tempDate)
                        }
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func updateTaskDate(taskId: String, date: Date?) {
        viewModel.updateTaskDate(taskId: taskId, date: date)

    }
}
