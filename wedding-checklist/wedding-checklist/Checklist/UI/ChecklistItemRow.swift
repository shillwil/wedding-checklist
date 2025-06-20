//
//  ChecklistItemRow.swift
//  wedding-checklist
//
//  Created by Alex Shillingford on 4/25/25.
//

import SwiftUI

struct ChecklistItemRow: View {
    let item: ChecklistItem
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        HStack {
            // Checkbox
            Button(action: onToggle) {
                Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.completed ? .green : .gray)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .fontWeight(.medium)
                    .strikethrough(item.completed)
                    .foregroundColor(item.completed ? .secondary : .primary)
                
                if let description = item.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 8) {
                    if let category = item.category {
                        Label(category, systemImage: "tag.fill")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                    
                    if let dueDate = item.formattedDueDate {
                        Label(dueDate, systemImage: "calendar")
                            .font(.caption2)
                            .foregroundColor(item.isOverdue ? .red : .secondary)
                    }
                }
            }
            
            Spacer()
            
            if item.isHighPriority {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: { showDeleteConfirmation = true }) {
                Label("Delete", systemImage: "trash")
            }
        }
        .confirmationDialog(
            "Delete Item",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive, action: onDelete)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete \"\(item.title)\"?")
        }
    }
}

//#Preview {
//    ChecklistItemRow()
//}
