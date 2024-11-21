//
//  TaskListView.swift
//  todo.calendar
//
//  Created by Lit Wa Yuen on 11/16/24.
//

import SwiftUI

struct TaskListView: View {
    @ObservedObject var viewModel: TaskViewModel
    var selectedDate: Date
    
    var body: some View {
        
        // Main List of Tasks
        List {
            ForEach(viewModel.tasks.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) { task in
                VStack(alignment: .leading) {
                    HStack {
                        
                        Toggle(isOn: Binding(
                            get: { task.isDone },
                            set: { newValue in
                                viewModel.markTaskAsDone(taskId: task.id!, isDone: task.isDone)
                            }
                        )) {
                            Text(task.title)
                                .strikethrough(task.isDone, color: .red)
                                .foregroundColor(task.isDone ? .gray : .primary)
                        }.toggleStyle(iOSCheckboxToggleStyle())
                        
                        
                    }
                    .padding(.vertical, 4)
                    
                    
                }
                .padding(.vertical, 4)
            }
        }
        
        
        
    }
}
