//
//  Task.swift
//  todo.calendar
//
//  Created by Lit Wa Yuen on 11/16/24.
//

import Foundation
import FirebaseFirestore

struct Subtask: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var isDone: Bool

    init(id: String = UUID().uuidString, title: String, isDone: Bool = false) {
        self.id = id
        self.title = title
        self.isDone = isDone
    }
}

struct Task: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var date: Date
    var isDone: Bool
    var subtasks: [Subtask] // New property for subtasks

    init(id: String = UUID().uuidString, title: String, description: String, date: Date, isDone: Bool = false, subtasks: [Subtask] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.isDone = isDone
        self.subtasks = subtasks
    }

    var dictionary: [String: Any] {
        return [
            "id": id,
            "title": title,
            "description": description,
            "date": date,
            "isDone": isDone,
            "subtasks": subtasks.map { $0.dictionary }
        ]
    }

    static func from(dictionary: [String: Any]) -> Task? {
        guard
            let id = dictionary["id"] as? String,
            let title = dictionary["title"] as? String,
            let description = dictionary["description"] as? String,
            let timestamp = dictionary["date"] as? Timestamp,
            let isDone = dictionary["isDone"] as? Bool,
            let subtasksArray = dictionary["subtasks"] as? [[String: Any]]
        else {
            return nil
        }

        let subtasks = subtasksArray.compactMap { Subtask.from(dictionary: $0) }
        return Task(id: id, title: title, description: description, date: timestamp.dateValue(), isDone: isDone, subtasks: subtasks)
    }
}

extension Subtask {
    var dictionary: [String: Any] {
        return [
            "id": id,
            "title": title,
            "isDone": isDone
        ]
    }

    static func from(dictionary: [String: Any]) -> Subtask? {
        guard
            let id = dictionary["id"] as? String,
            let title = dictionary["title"] as? String,
            let isDone = dictionary["isDone"] as? Bool
        else {
            return nil
        }

        return Subtask(id: id, title: title, isDone: isDone)
    }
}
