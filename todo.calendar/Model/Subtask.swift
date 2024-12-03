//
//  Subtask.swift
//  todo.calendar
//
//  Created by Lit Wa Yuen on 12/1/24.
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
