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
