//
//  ChecklistViewModel.swift
//  wedding-checklist
//
//  Created by Alex Shillingford on 4/25/25.
//

import Combine

class ChecklistViewModel: ObservableObject {
    @Published var items: [ChecklistItem] = []
    @Published var isLoading = false
    @Published var currentPage = 1
    @Published var totalPages = 1
    @Published var searchTerm = ""
    @Published var selectedCategory: String?
    
    private let service: ChecklistService
    
    init(service: ChecklistService) {
        self.service = service
    }
    
    func loadItems(resetPage: Bool = false) async {
        if resetPage {
            currentPage = 1
        }
        
        isLoading = true
        
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
                    self.items = response.items
                }
                self.totalPages = response.totalPages
                self.isLoading = false
            }
        } catch {
            print("Error loading items: \(error)")
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    func loadNextPage() async {
        if currentPage < totalPages {
            currentPage += 1
            await loadItems()
        }
    }
    
    func loadPreviousPage() async {
        if currentPage > 1 {
            currentPage -= 1
            await loadItems()
        }
    }
}
