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
    
    @State private var isModalPresented = false // State to control modal visibility
    
    var body: some View {
        VStack(alignment: .leading) {
            // Title Section
            VStack(alignment: .leading, spacing: 4) {
                Text("Today")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(selectedDate, style: .date) // Format: "November 16, 2024"
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            Divider()
            
            // Main List of Tasks
            List {
                ForEach(viewModel.tasks.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) { task in
                    HStack {
                        
                        Toggle(isOn: Binding(
                            get: { task.isDone },
                            set: { newValue in
                                viewModel.markTaskAsDone(taskId: task.id!, isDone: newValue)
                            }
                        )) {
                            //EmptyView() // Use EmptyView for Toggle's label
                        }
                        .toggleStyle(iOSCheckboxToggleStyle())
                        
                        
                        HStack {
                            
                            Text(task.title)
                                .strikethrough(task.isDone, color: .red)
                                .foregroundColor(task.isDone ? .gray : .primary)
                            
                            Spacer()
                            
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.selectedTask = task // Assign the tapped task
                            isModalPresented = true // Open the modal
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isModalPresented) {
            
            if let unwrappedTask = viewModel.selectedTask {
                EditTaskView(task: Binding(
                    get: { unwrappedTask },
                    set: { updatedTask in viewModel.selectedTask = updatedTask }
                ), viewModel: viewModel)
            }
            
        }
    }
}
