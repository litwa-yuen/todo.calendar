//
//  DatePickerButtonView.swift
//  todo.calendar
//
//  Created by Lit Wa Yuen on 11/27/24.
//

import SwiftUI

struct DatePickerButtonView: View {
    @State private var isModalPresented = false
    @Binding public var selectedDate: Date?
    
    var body: some View {

            Button(action: {
                isModalPresented = true
            }) {
                Text(selectedDate != nil ? formattedDate : "Set No Due Date")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .sheet(isPresented: $isModalPresented) {
                DatePickerModalView(selectedDate: $selectedDate)
            }
    }
    
    private var formattedDate: String {
        if let date = selectedDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        } else {
            return "No Due Date"
        }
    }
}
