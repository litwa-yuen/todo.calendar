//
//  TaskRowView.swift
//  todo.calendar
//
//  Created by Lit Wa Yuen on 11/26/24.
//

import SwiftUI

struct TaskRowView: View {
    let task: Task
    @ObservedObject var viewModel: TaskViewModel
    @State private var isModalPresented = false // State to control modal visibility
    
    var body: some View {
        HStack {
            Toggle(isOn: Binding(
                get: { task.isDone },
                set: { newValue in
                    viewModel.markTaskAsDone(taskId: task.id!, isDone: newValue)
                }
            )) {
                EmptyView()
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
}
