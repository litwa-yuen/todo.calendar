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
    @Published var selectedTask: Task? = nil
    @Published var selectedSubtask: Subtask? = nil
    @Published var subtasks: [Subtask] = []
    private var subtaskListener: ListenerRegistration? // Firestore listener
    
    
    @Published var errorMessage: String? = nil
    
    private var listenerRegistration: ListenerRegistration?
    
    public func unsubscribe() {
        if listenerRegistration != nil {
            listenerRegistration?.remove()
            listenerRegistration = nil
        }
    }
    
    func unsubscribeSubtask() {
        subtaskListener?.remove()
        subtaskListener = nil
    }
    
    func subscribeSubtask() {
        let taskRef = db.collection("tasks").document(selectedTask?.id! ?? "")
        
        subtaskListener = taskRef.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self, let data = snapshot?.data(), error == nil else {
                print("Failed to fetch subtasks: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            if let subtaskDictionaries = data["subtasks"] as? [[String: Any]] {
                self.subtasks = subtaskDictionaries.compactMap { Subtask.from(dictionary: $0) }
            }
            
        }
    }
    
    func subscribe() {
        if listenerRegistration == nil {
            listenerRegistration = db.collection("tasks")
                .addSnapshotListener { [weak self] (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        self?.errorMessage = "No documents in 'task' collection"
                        return
                    }
                    
                    self?.tasks = documents.compactMap { queryDocumentSnapshot in
                        let result = Result { try queryDocumentSnapshot.data(as: Task.self) }
                        
                        switch result {
                        case .success(let task):
                            self?.errorMessage = nil
                            return task
                        case .failure(let error):
                            // A ColorEntry value could not be initialized from the DocumentSnapshot.
                            switch error {
                            case DecodingError.typeMismatch(_, let context):
                                self?.errorMessage = "\(error.localizedDescription): \(context.debugDescription)"
                            case DecodingError.valueNotFound(_, let context):
                                self?.errorMessage = "\(error.localizedDescription): \(context.debugDescription)"
                            case DecodingError.keyNotFound(_, let context):
                                self?.errorMessage = "\(error.localizedDescription): \(context.debugDescription)"
                            case DecodingError.dataCorrupted(let key):
                                self?.errorMessage = "\(error.localizedDescription): \(key)"
                            default:
                                self?.errorMessage = "Error decoding document: \(error.localizedDescription)"
                            }
                            return nil
                        }
                    }
                }
        }
    }
    
    // Mark a task as done
    func markSubtaskAsDone(subtaskId: String, isDone: Bool) {
        let taskRef = db.collection("tasks").document(selectedTask?.id ?? "")
        
        taskRef.getDocument { (document, error) in
            guard let document = document, document.exists,
                  var taskData = document.data(),
                  var subtasks = taskData["subtasks"] as? [[String: Any]] else {
                print("Failed to retrieve subtasks or task data.")
                return
            }
            
            // Find the subtask and update its isDone field
            if let index = subtasks.firstIndex(where: { $0["id"] as? String == subtaskId }) {
                subtasks[index]["isDone"] = isDone
                
                // Update the Firestore document
                taskRef.updateData(["subtasks": subtasks]) { error in
                    if let error = error {
                        print("Error updating subtask: \(error.localizedDescription)")
                    } else {
                        print("Subtask updated successfully.")
                    }
                }
            } else {
                print("Subtask not found.")
            }
        }
    }
    
    func markTaskAsDone(taskId: String, isDone: Bool) {
        db.collection("tasks").document(taskId).updateData(["isDone": isDone, "date": Date()])
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
    
    func addSubtask(subtaskTitle: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let selectedTask = selectedTask,
              let taskIndex = tasks.firstIndex(where: { $0.id == selectedTask.id }) else {
            return
        }
        
        // Create a new Subtask
        let newSubtask = Subtask(id: UUID().uuidString, title: subtaskTitle, isDone: false)
        
        // Update the local task's subtasks
        tasks[taskIndex].subtasks.append(newSubtask)
        
        // Update Firestore
        let taskRef = db.collection("tasks").document(selectedTask.id ?? "")
        taskRef.updateData([
            "subtasks": FieldValue.arrayUnion([newSubtask.dictionary]) // Ensure newSubtask has a dictionary representation
        ]) { error in
            if let error = error {
                completion(.failure(error)) // Pass error back via completion handler
            } else {
                completion(.success(())) // Indicate success
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
    
    func updateTask() {
        guard let updateTask = self.selectedTask, let taskId = updateTask.id else {
            print("Error: Selected task is nil or does not have an ID")
            return
        }
        
        let docRef = db.collection("tasks").document(taskId)
        
        // Convert the task object to a dictionary for Firestore
        do {
            let taskData = try Firestore.Encoder().encode(updateTask) // Convert to dictionary
            docRef.updateData(taskData) { error in
                if let error = error {
                    print("Error updating task: \(error.localizedDescription)")
                } else {
                    print("Task updated successfully!")
                }
            }
        } catch {
            print("Error encoding task: \(error.localizedDescription)")
        }
    }
    
    
    //TODO: merge markSubtaskAsDone
    func updateSubtask(title: String, isDone: Bool) {
        let taskRef = db.collection("tasks").document(selectedTask?.id ?? "")
        
        taskRef.getDocument { (document, error) in
            guard let document = document, document.exists,
                  let taskData = document.data(),
                  var subtasks = taskData["subtasks"] as? [[String: Any]] else {
                print("Failed to retrieve subtasks or task data.")
                return
            }
            
            // Find the subtask and update its isDone field
            if let index = subtasks.firstIndex(where: { $0["id"] as? String == self.selectedSubtask?.id ?? "" }) {
                subtasks[index]["isDone"] = isDone
                subtasks[index]["title"] = title
                
                // Update the Firestore document
                taskRef.updateData(["subtasks": subtasks]) { error in
                    if let error = error {
                        print("Error updating subtask: \(error.localizedDescription)")
                    } else {
                        print("Subtask updated successfully.")
                    }
                }
            } else {
                print("Subtask not found.")
            }
        }
    }
    
}

