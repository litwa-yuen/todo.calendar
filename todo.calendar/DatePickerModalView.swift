//
//  DatePickerModalView.swift
//  todo.calendar
//
//  Created by Lit Wa Yuen on 11/27/24.
//

import SwiftUI

struct DatePickerModalView: View {
    @Binding var selectedDate: Date?
    @Environment(\.dismiss) var dismiss // To close the modal
    @State private var tempDate: Date = Date() // Temporary date for selection
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    // Date Picker Section
                    Section(header: Text("Select a Date")) {
                        DatePicker("Due Date", selection: $tempDate, displayedComponents: .date)
                    }
                    
                    // No Due Date Option
                    Section {
                        Button("No Due Date") {
                            selectedDate = nil
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
                        selectedDate = tempDate
                        dismiss()
                    }
                }
            }
        }
    }
}
