//
//  TaskViewModel.swift
//  todo.calendar
//
//  Created by Lit Wa Yuen on 11/16/24.
//


import FirebaseFirestore

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    private let db = Firestore.firestore()

    // Fetch tasks from Firestore
    func fetchTasks() {
        db.collection("tasks")
            .order(by: "date")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("No documents: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                self.tasks = documents.compactMap { doc in
                    try? doc.data(as: Task.self)
                }
            }
    }

    // Add a new task
    func addTask(title: String, description: String, date: Date, completion: @escaping (Result<Void, Error>) -> Void) {
        let newTask = Task(id: UUID().uuidString, title: title, description: description, date: date, isDone: false)
        db.collection("tasks").document(newTask.id!).setData(newTask.dictionary) { error in
            if let error = error {
                completion(.failure(error)) // Pass error back via completion handler
            } else {
                completion(.success(())) // Indicate success
            }
        }
    }
    
    func addSubtask(to taskId: String, subtaskTitle: String) {
        guard let taskIndex = tasks.firstIndex(where: { $0.id == taskId }) else { return }

        let newSubtask = Subtask(title: subtaskTitle)
        tasks[taskIndex].subtasks.append(newSubtask)

        // Update Firestore
        let taskRef = db.collection("tasks").document(taskId)
        taskRef.updateData([
            "subtasks": tasks[taskIndex].subtasks.map { $0.dictionary }
        ]) { error in
            if let error = error {
                print("Error adding subtask: \(error.localizedDescription)")
            }
        }
    }

    // Mark a task as done
    func markTaskAsDone(taskId: String, isDone: Bool) {
        db.collection("tasks").document(taskId).updateData(["isDone": !isDone, "date": Date()]) { error in
            if let error = error {
                print("Error updating task: \(error.localizedDescription)")
            }
        }
    }
    
    func markSubtaskAsDone(taskId: String, subtaskId: String) {
        guard let taskIndex = tasks.firstIndex(where: { $0.id == taskId }),
              let subtaskIndex = tasks[taskIndex].subtasks.firstIndex(where: { $0.id == subtaskId })
        else { return }

        tasks[taskIndex].subtasks[subtaskIndex].isDone.toggle()

        // Update Firestore
        let taskRef = db.collection("tasks").document(taskId)
        taskRef.updateData([
            "subtasks": tasks[taskIndex].subtasks.map { $0.dictionary }
        ]) { error in
            if let error = error {
                print("Error updating subtask: \(error.localizedDescription)")
            }
        }
    }


    // Delete a task
    func deleteTask(taskId: String) {
        db.collection("tasks").document(taskId).delete { error in
            if let error = error {
                print("Error deleting task: \(error.localizedDescription)")
            }
        }
    }
}

