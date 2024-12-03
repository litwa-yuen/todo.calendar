//
//  TaskViewModel.swift
//  todo.calendar
//
//  Created by Lit Wa Yuen on 11/16/24.
//


import FirebaseFirestore
import FirebaseAuth

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    private let db = Firestore.firestore()
    @Published var selectedTask: Task? = nil
    @Published var selectedSubtask: Subtask? = nil
    @Published var subtasks: [Subtask] = []
    private var subtaskListener: ListenerRegistration? // Firestore listener
    private var user: User? // Firebase User
    
    
    @Published var errorMessage: String? = nil
    
    private var listenerRegistration: ListenerRegistration?
    
    init() {
        
        observeAuthState()
    }
    
    
    private func signOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            DispatchQueue.main.async {
                UserDefaults.standard.set(false, forKey: "isSignedIn")
            }
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    private func observeAuthState() {
        _ = Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            self?.user = user
            if let user = user {
                print("Firebase user: \(user.uid)")
                self?.subscribe(selectedDate: Date(), isNext7Days: false)
                //self?.signOut()
            } else {
                self?.unsubscribe()
                self?.tasks.removeAll()
            }
        }
    }
    
    
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
        guard let user = user, let selectedTask = selectedTask else { return }
        let taskRef = db.collection("users").document(user.uid).collection("tasks").document(selectedTask.id ?? "")
        
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
    
    
    func getStartAndEndOfDay(for date: Date, isNext7Days: Bool) -> (startOfDay: Timestamp, endOfDay: Timestamp) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date) // Midnight of the given day
        guard let endOfDay = calendar.date(byAdding: .day, value: (isNext7Days ? 7 : 1), to: startOfDay) else {
            fatalError("Failed to calculate end of day")
        }
        return (Timestamp(date: startOfDay), Timestamp(date: endOfDay))
    }
    
    func subscribe(selectedDate: Date?, isNext7Days: Bool) {
        guard let user else { return }
        var query: Query!
        if let selectedDate {
            let (startOfDay, endOfDay) = getStartAndEndOfDay(for: selectedDate, isNext7Days: isNext7Days)
            query = db.collection("users").document(user.uid).collection("tasks")
                .whereField("date", isGreaterThanOrEqualTo: startOfDay)
                .whereField("date", isLessThan: endOfDay)
        } else {
            query = db.collection("users").document(user.uid).collection("tasks")
                .whereField("date", isEqualTo: NSNull())
        }
        tasks.removeAll()
        
        listenerRegistration = query
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
    
    func markTaskAsDone(taskId: String, isDone: Bool) {
        guard let user = user else { return }
        db.collection("users").document(user.uid).collection("tasks").document(taskId).updateData(["isDone": isDone])
    }
    
    func getNewTaskId() -> String {
        guard let user = user else { return "" }
        let userTasksRef = db.collection("users").document(user.uid).collection("tasks")
        return userTasksRef.document().documentID
    }
    
    // Add a new task
    func addTask(taskId: String, title: String, description: String, reminder: Reminder, /*recurring: Recurring,*/ date: Date?, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = user else { return }
        var newTask = Task(title: title, description: description, isDone: false, reminder: reminder, /*recurring: recurring,*/ subtasks: [])
        
        if let date = date {
            newTask.date = date
        }
        let userTasksRef = db.collection("users").document(user.uid).collection("tasks")
        
        let newTaskId = userTasksRef.document().documentID
        newTask.id = newTaskId
        userTasksRef.document(newTaskId).setData(newTask.dictionary) { error in
            if let error = error {
                completion(.failure(error)) // Pass error back via completion handler
            } else {
                completion(.success(())) // Indicate success
            }
        }
    }
    
    func addSubtask(subtaskTitle: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = user else { return }
        guard let selectedTaskId = selectedTask?.id else { return }
        
        let userTasksRef = db.collection("users").document(user.uid).collection("tasks")
        
        let newSubtaskId = userTasksRef.document(selectedTaskId).collection("subtasks").document().documentID
        
        // Create a new Subtask
        var newSubtask = Subtask(title: subtaskTitle, isDone: false)
        newSubtask.id = newSubtaskId
        // Update Firestore
        
        userTasksRef.document(selectedTaskId).updateData([
            "subtasks": FieldValue.arrayUnion([newSubtask.dictionary]) // Ensure newSubtask has a dictionary representation
        ]) { error in
            if let error = error {
                completion(.failure(error)) // Pass error back via completion handler
            } else {
                completion(.success(())) // Indicate success
            }
        }
    }
    
    // Delete a task
    func deleteTask(taskId: String) {
        guard let user = user else { return }
        db.collection("users").document(user.uid).collection("tasks").document(taskId).delete { error in
            if let error = error {
                print("Error deleting task: \(error.localizedDescription)")
            }
        }
    }
    
    func updateTask() {
        guard let updateTask = self.selectedTask, let taskId = updateTask.id, let user = user else {
            print("Error: Selected task is nil or does not have an ID")
            return
        }
        
        db.collection("users").document(user.uid).collection("tasks").document(taskId)
            .updateData(["isDone": updateTask.isDone, "title": updateTask.title, "description": updateTask.description, "date": updateTask.date])
    }
    
    func updateTaskDate(taskId: String, date: Date?) {
        guard let user = user else { return }
        let dateValue: Any = date ?? NSNull()
        db.collection("users").document(user.uid).collection("tasks").document(taskId).updateData(["date": dateValue]) { error in
            if let error = error {
                print("Error updating task date: \(error.localizedDescription)")
            } else {
                print("Task date updated successfully.")
            }
        }
    }
    
    func updateSubtask(subtaskId: String, title: String, isDone: Bool) {
        guard let user = user, let selectedTask else { return }
        let userTasksRef = db.collection("users").document(user.uid).collection("tasks").document(selectedTask.id!)
        
        userTasksRef.getDocument { (document, error) in
            guard let document = document, document.exists,
                  let taskData = document.data(),
                  var subtasks = taskData["subtasks"] as? [[String: Any]] else {
                print("Failed to retrieve subtasks or task data.")
                return
            }
            
            // Find the subtask and update its isDone field
            if let index = subtasks.firstIndex(where: { $0["id"] as? String == subtaskId }) {
                subtasks[index]["isDone"] = isDone
                subtasks[index]["title"] = title
                
                // Update the Firestore document
                userTasksRef.updateData(["subtasks": subtasks]) { error in
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

