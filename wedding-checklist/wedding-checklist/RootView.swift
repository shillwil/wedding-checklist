//
//  RootView.swift
//  wedding-checklist
//
//  Created by Alex Shillingford on 6/14/25.
//

import SwiftUI

struct RootView: View {
    @StateObject private var authService = AuthService()
    
    var body: some View {
        Group {
            if authService.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            } else if authService.isAuthenticated {
                ContentView()
                    .environmentObject(authService)
            } else {
                LoginView()
                    .environmentObject(authService)
            }
        }
    }
}


#Preview {
    RootView()
}
