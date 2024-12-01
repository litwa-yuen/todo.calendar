//
//  EditSubtaskView.swift
//  todo.calendar
//
//  Created by Lit Wa Yuen on 11/25/24.
//

import SwiftUI

struct EditSubtaskView: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var subtaskTitle: String
    @State private var isDone: Bool
    var subtaskId: String
    @Environment(\.dismiss) var dismiss

    init(viewModel: TaskViewModel, subtask: Subtask) {
        self.viewModel = viewModel
        _subtaskTitle = State(initialValue: subtask.title)
        _isDone = State(initialValue: subtask.isDone)
        subtaskId = subtask.id!
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Subtask Title")) {
                    TextField("Enter subtask title", text: $subtaskTitle)
                }
                
                Section {
                    Toggle("Is Done", isOn: $isDone)
                }
                
                Section {
                    Button("Save") {
                        saveSubtask(subtaskId: subtaskId)
                    }
                    .disabled(subtaskTitle.isEmpty)
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }

    private func saveSubtask(subtaskId: String) {
        viewModel.updateSubtask(subtaskId: subtaskId, title: subtaskTitle, isDone: isDone)
        dismiss()
    }
}
