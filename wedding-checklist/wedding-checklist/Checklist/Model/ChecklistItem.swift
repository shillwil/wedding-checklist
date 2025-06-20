//
//  ChecklistItem.swift
//  wedding-checklist
//
//  Created by Alex Shillingford on 4/25/25.
//

import Foundation
struct ChecklistItem: Identifiable, Codable {
    let id: String
    var title: String
    var description: String?
    var category: String?
    var completed: Bool
    var dueDate: Date?
    var priority: Int
    var createdAt: Date
    var updatedAt: Date
    
    // MARK: - Computed Properties
    
    /// Formats the due date for display
    var formattedDueDate: String? {
        guard let dueDate = dueDate else { return nil }
        
        let formatter = DateFormatter()
        
        // Use relative formatting for dates within a week
        let daysUntilDue = Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
        
        if daysUntilDue == 0 {
            return "Today"
        } else if daysUntilDue == 1 {
            return "Tomorrow"
        } else if daysUntilDue == -1 {
            return "Yesterday"
        } else if daysUntilDue > 1 && daysUntilDue <= 7 {
            // Show day of week for next week
            formatter.dateFormat = "EEEE" // "Monday", "Tuesday", etc.
            return formatter.string(from: dueDate)
        } else {
            // Show full date for everything else
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: dueDate)
        }
    }
    
    /// Alternative simpler date formatting
    var simplifiedFormattedDate: String? {
        guard let dueDate = dueDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium  // "Jan 23, 2024"
        formatter.timeStyle = .none
        return formatter.string(from: dueDate)
    }
    
    /// Returns true if the item has high priority (1 or 2)
    var isHighPriority: Bool {
        priority <= 2
    }
    
    /// Returns true if the item is overdue
    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return dueDate < Date() && !completed
    }
    
    /// Returns number of days until due (negative if overdue)
    var daysUntilDue: Int? {
        guard let dueDate = dueDate else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: dueDate)
        return components.day
    }
    
    /// Returns a user-friendly priority label
    var priorityLabel: String {
        switch priority {
        case 1: return "High"
        case 2: return "Medium"
        case 3: return "Normal"
        case 4: return "Low"
        default: return "Normal"
        }
    }
    
    /// Returns the appropriate color for priority
    var priorityColor: String {
        switch priority {
        case 1: return "red"
        case 2: return "orange"
        case 3: return "blue"
        case 4: return "gray"
        default: return "blue"
        }
    }
    
    /// Returns a status description
    var statusDescription: String {
        if completed {
            return "Completed"
        } else if isOverdue {
            return "Overdue"
        } else if let days = daysUntilDue {
            if days == 0 {
                return "Due today"
            } else if days == 1 {
                return "Due tomorrow"
            } else if days < 0 {
                return "\(abs(days)) days overdue"
            } else {
                return "\(days) days remaining"
            }
        } else {
            return "No due date"
        }
    }
    
    /// Returns true if this item should be highlighted (overdue or due today)
    var needsAttention: Bool {
        guard !completed else { return false }
        
        if isOverdue { return true }
        
        if let days = daysUntilDue, days <= 0 {
            return true
        }
        
        return false
    }
}

struct PaginatedResponse: Codable {
    let items: [ChecklistItem]
    let totalCount: Int
    let currentPage: Int
    let totalPages: Int
}

extension ChecklistItem {
    /// Returns items sorted by urgency (overdue first, then by due date, then by priority)
    static func sortedByUrgency(_ items: [ChecklistItem]) -> [ChecklistItem] {
        return items.sorted { item1, item2 in
            // Completed items go to the bottom
            if item1.completed != item2.completed {
                return !item1.completed
            }
            
            // Overdue items first
            if item1.isOverdue != item2.isOverdue {
                return item1.isOverdue
            }
            
            // Then by due date (earliest first)
            if let date1 = item1.dueDate, let date2 = item2.dueDate {
                return date1 < date2
            }
            
            // Items with due dates before items without
            if item1.dueDate != nil && item2.dueDate == nil {
                return true
            }
            if item1.dueDate == nil && item2.dueDate != nil {
                return false
            }
            
            // Finally by priority
            return item1.priority < item2.priority
        }
    }
}
