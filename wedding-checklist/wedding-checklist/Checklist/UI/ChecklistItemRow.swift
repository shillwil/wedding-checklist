//
//  ChecklistItemRow.swift
//  wedding-checklist
//
//  Created by Alex Shillingford on 4/25/25.
//

import SwiftUI

struct ChecklistItemRow: View {
    let item: ChecklistItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.title)
                    .fontWeight(.medium)
                
                if let description = item.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let category = item.category {
                    Text(category)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray6))
                        .cornerRadius(4)
                }
            }
            
            Spacer()
            
            if item.priority <= 2 {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.orange)
            }
            
            // Here you would add your checkbox or completion indicator
        }
        .padding(.vertical, 4)
    }
}

//#Preview {
//    ChecklistItemRow()
//}
