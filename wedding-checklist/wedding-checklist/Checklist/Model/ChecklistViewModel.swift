//
//  ChecklistViewModel.swift
//  wedding-checklist
//
//  Created by Alex Shillingford on 4/25/25.
//

import Combine
import Foundation

class ChecklistViewModel: ObservableObject {
    @Published var items: [ChecklistItem] = []
    @Published var isLoading = false
    @Published var currentPage = 1
    @Published var totalPages = 1
    @Published var searchTerm = ""
    @Published var selectedCategory: String?
    @Published var errorMessage: String?
    @Published var showError = false
    
    private let service: ChecklistService
    private var loadTask: Task<Void, Never>?
    
    init(service: ChecklistService) {
        self.service = service
    }
    
    func loadItems(resetPage: Bool = false) async {
        if resetPage {
            currentPage = 1
            items = []
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let response = try await service.fetchItems(
                page: currentPage,
                category: selectedCategory,
                searchTerm: searchTerm.isEmpty ? nil : searchTerm
            )
            
            await MainActor.run {
                if resetPage {
                    self.items = response.items
                } else {
                    self.items.append(contentsOf: response.items)
                }
                self.totalPages = response.totalPages
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.showError = true
                self.isLoading = false
            }
        }
    }
    
    func createItem(title: String, description: String?, category: String?, dueDate: Date?, priority: Int) async {
        do {
            let newItem = try await service.createItem(
                title: title,
                description: description,
                category: category,
                dueDate: dueDate,
                priority: priority
            )
            
            await MainActor.run {
                self.items.insert(newItem, at: 0)
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }
    
    func toggleItemCompletion(_ item: ChecklistItem) async {
        do {
            let updatedItem = try await service.toggleItemCompletion(
                id: item.id,
                completed: !item.completed
            )
            
            await MainActor.run {
                if let index = self.items.firstIndex(where: { $0.id == item.id }) {
                    self.items[index] = updatedItem
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }
    
    func deleteItem(_ item: ChecklistItem) async {
        do {
            try await service.deleteItem(id: item.id)
            
            await MainActor.run {
                self.items.removeAll { $0.id == item.id }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }
    
    func refresh() async {
        await loadItems(resetPage: true)
    }
    
    func loadNextPage() async {
        guard currentPage < totalPages, !isLoading else { return }
        currentPage += 1
        await loadItems()
    }
    
    func searchItems(_ searchText: String) {
        loadTask?.cancel()
        
        searchTerm = searchText
        
        loadTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms debounce
            await loadItems(resetPage: true)
        }
    }
}
