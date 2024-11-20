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
        ZStack {
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
            
            // Floating Add Task Button
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        viewModel.addTask(title: "New Task", description: "Description", date: selectedDate)
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white)
                            .background(Circle().fill(Color.blue))
                            .shadow(radius: 4)
                    }
                    .padding()
                }
            }
        }
    }
}
