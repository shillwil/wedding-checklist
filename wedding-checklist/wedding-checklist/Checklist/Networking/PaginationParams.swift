//
//  PaginationParams.swift
//  wedding-checklist
//
//  Created by Alex Shillingford on 4/25/25.
//

import Foundation

struct PaginationParams: Encodable {
    let page_number: Int
    let items_per_page: Int
    let filter_category: String?
    let search_term: String?
    let sort_field: String
    let sort_direction: String
    
    init(
        page: Int,
        itemsPerPage: Int,
        category: String? = nil,
        searchTerm: String? = nil,
        sortField: String = "priority",
        sortDirection: String = "ASC"
    ) {
        self.page_number = page
        self.items_per_page = itemsPerPage
        self.filter_category = category
        self.search_term = searchTerm
        self.sort_field = sortField
        self.sort_direction = sortDirection
    }
}
