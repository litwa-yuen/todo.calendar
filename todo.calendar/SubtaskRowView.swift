//
//  SubtaskRowView.swift
//  todo.calendar
//
//  Created by Lit Wa Yuen on 11/24/24.
//

import SwiftUI

struct SubtaskRowView: View {
    let subtask: Subtask
    @ObservedObject var viewModel: TaskViewModel
    @State private var isModalPresented = false // State to control modal visibility
    
    var body: some View {
        HStack {
            Toggle(isOn: Binding(
                get: { subtask.isDone },
                set: { newValue in
                    viewModel.markSubtaskAsDone(subtaskId: subtask.id!, isDone: newValue)
                }
            )) {
                EmptyView()
            }
            .toggleStyle(iOSCheckboxToggleStyle())
            
            HStack {
                
                Text(subtask.title)
                    .strikethrough(subtask.isDone, color: .red)
                    .foregroundColor(subtask.isDone ? .gray : .primary)
                
                Spacer()
                
            }
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.selectedSubtask = subtask // Assign the tapped task
                isModalPresented = true // Open the modal
            }
            .sheet(isPresented: $isModalPresented) {
                EditSubtaskView(viewModel: viewModel, subtask: subtask)
            }
        }
    }
}
