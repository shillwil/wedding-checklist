//
//  EmptyStateView.swift
//  wedding-checklist
//
//  Created by Alex Shillingford on 6/19/25.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checklist")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No items yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tap the + button to add your first wedding checklist item")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView()
}
