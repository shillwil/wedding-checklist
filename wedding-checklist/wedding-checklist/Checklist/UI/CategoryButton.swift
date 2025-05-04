//
//  CategoryButton.swift
//  wedding-checklist
//
//  Created by Alex Shillingford on 4/25/25.
//

import SwiftUI

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

//#Preview {
//    CategoryButton()
//}
