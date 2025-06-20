//
//  AuthService.swift
//  wedding-checklist
//
//  Created by Alex Shillingford on 6/14/25.
//

import Foundation
import FirebaseAuth
import Combine

class AuthService: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoading = true
    
    private var handle: AuthStateDidChangeListenerHandle?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        checkAuthState()
    }
    
    func checkAuthState() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
                self?.isAuthenticated = user != nil
                self?.isLoading = false
            }
        }
    }
    
    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        await MainActor.run {
            self.user = result.user
            self.isAuthenticated = true
        }
    }
    
    func signUp(email: String, password: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        
        // Sync user with your backend
        try await syncUserWithBackend(firebaseUser: result.user)
        
        await MainActor.run {
            self.user = result.user
            self.isAuthenticated = true
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        user = nil
        isAuthenticated = false
    }
    
    func getIDToken() async throws -> String {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.noUser
        }
        return try await user.getIDToken()
    }
    
    private func syncUserWithBackend(firebaseUser: User) async throws {
        let token = try await firebaseUser.getIDToken()
        
        var request = URLRequest(url: URL(string: "\(Config.apiBaseURL)/api/auth/sync")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "uid": firebaseUser.uid,
            "email": firebaseUser.email ?? ""
        ]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AuthError.syncFailed
        }
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}

enum AuthError: LocalizedError {
    case noUser
    case syncFailed
    
    var errorDescription: String? {
        switch self {
        case .noUser:
            return "No authenticated user found"
        case .syncFailed:
            return "Failed to sync user with backend"
        }
    }
}
