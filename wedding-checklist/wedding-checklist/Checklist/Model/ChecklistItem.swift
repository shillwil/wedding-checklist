//
//  ChecklistItem.swift
//  wedding-checklist
//
//  Created by Alex Shillingford on 4/25/25.
//

import Foundation
struct ChecklistItem: Identifiable, Codable {
    let id: Int
    var title: String
    var description: String?
    var category: String?
    var completed: Bool
    var dueDate: Date?
    var priority: Int
    var createdAt: Date
    var updatedAt: Date
}

struct PaginatedResponse: Codable {
    let items: [ChecklistItem]
    let totalCount: Int
    let currentPage: Int
    let totalPages: Int
}
