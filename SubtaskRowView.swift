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

    var body: some View {
        HStack {
            Toggle(isOn: Binding(
                get: { subtask.isDone },
                set: { newValue in
                    //viewModel.updateSubtaskStatus(subtaskId: subtask.id, isDone: newValue)
                }
            )) {
                Text(subtask.title)
                    .strikethrough(subtask.isDone, color: .red)
            }
        }
    }
}
