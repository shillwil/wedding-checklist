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
        
        // After sign in, ensure user exists in backend
        try await syncUserWithBackend(firebaseUser: result.user)
        
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
        
        guard let url = URL(string: "\(Config.apiBaseURL)/api/auth/sync") else {
            throw AuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "uid": firebaseUser.uid,
            "email": firebaseUser.email ?? "",
            "name": firebaseUser.displayName ?? firebaseUser.email?.split(separator: "@").first.map(String.init) ?? "User"
        ]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.syncFailed
        }
        
        if httpResponse.statusCode == 404 {
            // User not found, this might be their first sync
            print("User sync completed")
        } else if httpResponse.statusCode != 200 {
            print("Sync failed with status: \(httpResponse.statusCode)")
            if let errorData = try? JSONDecoder().decode([String: String].self, from: data) {
                print("Error: \(errorData)")
            }
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
    case invalidURL
    
    var errorDescription: String? {
        switch self {
        case .noUser:
            return "No authenticated user found"
        case .syncFailed:
            return "Failed to sync user with backend"
        case .invalidURL:
            return "Invalid server URL"
        }
    }
}
