//
//  ChecklistService.swift
//  wedding-checklist
//
//  Created by Alex Shillingford on 4/25/25.
//

import Foundation
import Supabase

class ChecklistService {
    private let supabaseClient: SupabaseClient
    private let itemsPerPage = 30 // Adjust based on UI design
    
    init(
        supabaseClient: SupabaseClient = .init(supabaseURL: SupabaseConfig.projectURL, supabaseKey: SupabaseConfig.apiKey)
    ) {
        self.supabaseClient = supabaseClient
    }
    
    func fetchItems(
        page: Int,
        category: String? = nil,
        searchTerm: String? = nil,
        sortField: String = "priority",
        sortDirection: String = "ASC"
    ) async throws -> PaginatedResponse {
        
        let queryParams = ChecklistQueryParams(
            page_number: page,
            items_per_page: itemsPerPage,
            filter_category: category,
            search_term: searchTerm,
            sort_field: sortField,
            sort_direction: sortDirection
        )
        
        let result: PaginatedResult<ChecklistItem> = try await supabaseClient.functions.invoke(
            "get_paginated_checklist_items",
            options: .init(body: queryParams)
        )
        
        return PaginatedResponse(
            items: result.items,
            totalCount: result.totalCount,
            currentPage: result.page,
            totalPages: result.totalPages
        )
    }
}
