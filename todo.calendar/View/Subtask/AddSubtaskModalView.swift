//
//  AddSubtaskModalView.swift
//  todo.calendar
//
//  Created by Lit Wa Yuen on 11/24/24.
//

import SwiftUI

struct AddSubtaskModalView: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var taskTitle: String = ""
    @Environment(\.presentationMode) private var presentationMode // For dismissing the modal
    @State private var showAlert = false
    @State private var alertMessage = ""
    @FocusState private var isTaskTitleFocused: Bool // Focus state for the text field
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Subtask title", text: $taskTitle)
                    .focused($isTaskTitleFocused) // Bind the focus state
                    .padding()
            }
          
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer() // Push the button to the right
                    Button("Save Subtask") {
                        saveAndReset()
                    }
                    .disabled(taskTitle.isEmpty) // Disable if title is empty
                }
            }
            .onAppear {
                isTaskTitleFocused = true // Automatically focus when the modal appears
            }
            .navigationBarHidden(true)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            
        }
        .ignoresSafeArea()
    }
    
    private func saveAndReset() {
        guard !taskTitle.isEmpty else { return }
        
        viewModel.addSubtask(subtaskTitle: taskTitle) { result in
            switch result {
            case .success:
                taskTitle = "" // Reset the text field for adding the next subtask
            case .failure(let error):
                alertMessage = "Failed to add subtask: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
}
