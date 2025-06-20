//
//  ChecklistService.swift
//  wedding-checklist
//
//  Created by Alex Shillingford on 4/25/25.
//

import Foundation
import Combine

class ChecklistService {
    private let baseURL = Config.apiBaseURL
    private let authService: AuthService
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    init(authService: AuthService) {
        self.authService = authService
        
        // Configure decoder for dates
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
    }
    
    // MARK: - Fetch Items
    func fetchItems(
        page: Int = 1,
        category: String? = nil,
        searchTerm: String? = nil,
        sortField: String = "priority",
        sortDirection: String = "asc"
    ) async throws -> PaginatedResponse {
        // Build URL with query parameters
        var components = URLComponents(string: "\(baseURL)/api/checklist")!
        components.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "limit", value: "30"),
            URLQueryItem(name: "sortField", value: sortField),
            URLQueryItem(name: "sortDirection", value: sortDirection)
        ]
        
        if let category = category {
            components.queryItems?.append(URLQueryItem(name: "category", value: category))
        }
        
        if let searchTerm = searchTerm, !searchTerm.isEmpty {
            components.queryItems?.append(URLQueryItem(name: "search", value: searchTerm))
        }
        
        // Create request with auth token
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        
        let token = try await authService.getIDToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Perform request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            print("STATUS CODE ON LINE \(#line): \(String(describing: (response as? HTTPURLResponse)?.statusCode)), \((response as? HTTPURLResponse)?.allHeaderFields)")
            throw NetworkError.invalidResponse
        }
        
        let paginatedResponse = try decoder.decode(PaginatedResponse.self, from: data)
        return paginatedResponse
    }
    
    // MARK: - Create Item
    func createItem(
        title: String,
        description: String? = nil,
        category: String? = nil,
        dueDate: Date? = nil,
        priority: Int = 3
    ) async throws -> ChecklistItem {
        let url = URL(string: "\(baseURL)/api/checklist")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let token = try await authService.getIDToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = CreateItemRequest(
            title: title,
            description: description,
            category: category,
            dueDate: dueDate,
            priority: priority
        )
        
        request.httpBody = try encoder.encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            print("STATUS CODE ON LINE \(#line): \(String(describing: (response as? HTTPURLResponse)?.statusCode)), \((response as? HTTPURLResponse)?.allHeaderFields)")
            throw NetworkError.invalidResponse
        }
        
        return try decoder.decode(ChecklistItem.self, from: data)
    }
    
    // MARK: - Update Item
    func updateItem(id: String, updates: ItemUpdate) async throws -> ChecklistItem {
        let url = URL(string: "\(baseURL)/api/checklist/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        
        let token = try await authService.getIDToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try encoder.encode(updates)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            print("STATUS CODE ON LINE \(#line): \(String(describing: (response as? HTTPURLResponse)?.statusCode)), \((response as? HTTPURLResponse)?.allHeaderFields)")
            throw NetworkError.invalidResponse
        }
        
        return try decoder.decode(ChecklistItem.self, from: data)
    }
    
    // MARK: - Toggle Completion
    func toggleItemCompletion(id: String, completed: Bool) async throws -> ChecklistItem {
        let updates = ItemUpdate(completed: completed)
        return try await updateItem(id: id, updates: updates)
    }
    
    // MARK: - Delete Item
    func deleteItem(id: String) async throws {
        let url = URL(string: "\(baseURL)/api/checklist/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let token = try await authService.getIDToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            print("STATUS CODE ON LINE \(#line): \(String(describing: (response as? HTTPURLResponse)?.statusCode)), \((response as? HTTPURLResponse)?.allHeaderFields)")
            throw NetworkError.invalidResponse
        }
    }
}

// MARK: - Supporting Types
struct CreateItemRequest: Encodable {
    let title: String
    let description: String?
    let category: String?
    let dueDate: Date?
    let priority: Int
}

struct ItemUpdate: Encodable {
    var title: String? = nil
    var description: String? = nil
    var category: String? = nil
    var completed: Bool? = nil
    var dueDate: Date? = nil
    var priority: Int? = nil
}

enum NetworkError: LocalizedError {
    case invalidResponse
    case decodingError
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError:
            return "Failed to decode response"
        case .unauthorized:
            return "Unauthorized - Please sign in again"
        }
    }
}
