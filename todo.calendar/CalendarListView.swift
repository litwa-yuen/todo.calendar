//
//  CalendarListView.swift
//  todo.calendar
//
//  Created by Lit Wa Yuen on 11/19/24.
//

import SwiftUI

struct CalendarListView: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var currentWeekStartDate: Date = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                // Week Navigation Controls
                HStack {
                    Button(action: {
                        currentWeekStartDate = Calendar.current.date(byAdding: .day, value: -7, to: currentWeekStartDate) ?? currentWeekStartDate
                    }) {
                        Image(systemName: "chevron.left")
                            .padding()
                    }
                    
                    Spacer()
                    
                    Text(weekDateRangeText)
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: {
                        currentWeekStartDate = Calendar.current.date(byAdding: .day, value: 7, to: currentWeekStartDate) ?? currentWeekStartDate
                    }) {
                        Image(systemName: "chevron.right")
                            .padding()
                    }
                }
                .padding(.horizontal)
                
                // Task List for the Week
                List {
                    ForEach(0..<7, id: \.self) { offset in
                        let date = Calendar.current.date(byAdding: .day, value: offset, to: currentWeekStartDate)!
                        Section(header: Text(dateFormatted(date))) {
                            let dailyTasks = viewModel.tasks.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
                            if dailyTasks.isEmpty {
                                Text("No tasks for this day")
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(dailyTasks) { task in
                                    HStack {
                                        Text(task.title)
                                            .strikethrough(task.isDone, color: .red)
                                            .foregroundColor(task.isDone ? .gray : .primary)
                                        
                                        Spacer()
                                        
                                        if task.isDone {
                                            Text("Done")
                                                .foregroundColor(.green)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
            .navigationTitle("Calendar")
        }
        
    }
    
    // Helper function to format date as "MMM d, yyyy"
    private func dateFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    // Helper function to show week range as "MMM d - MMM d, yyyy"
    private var weekDateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        let endDate = Calendar.current.date(byAdding: .day, value: 6, to: currentWeekStartDate) ?? currentWeekStartDate
        return "\(formatter.string(from: currentWeekStartDate)) - \(formatter.string(from: endDate))"
    }
}
