//
//  ContentView.swift
//  wedding-checklist
//
//  Created by Alex Shillingford on 4/17/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
        
    var body: some View {
        ChecklistView(authService: authService)
    }
}

#Preview {
    ContentView()
}
