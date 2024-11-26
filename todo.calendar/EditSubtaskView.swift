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
    @Environment(\.dismiss) var dismiss

    init(viewModel: TaskViewModel, subtask: Subtask) {
        self.viewModel = viewModel
        _subtaskTitle = State(initialValue: subtask.title)
        _isDone = State(initialValue: subtask.isDone)
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
                        saveSubtask()
                    }
                    .disabled(subtaskTitle.isEmpty)
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Edit Subtask")
        }
    }

    private func saveSubtask() {
        viewModel.updateSubtask(title: subtaskTitle, isDone: isDone)
        dismiss()
    }
}
