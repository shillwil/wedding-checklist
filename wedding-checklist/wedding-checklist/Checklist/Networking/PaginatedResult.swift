//
//  ChecklistPaginatedResponse.swift
//  wedding-checklist
//
//  Created by Alex Shillingford on 5/3/25.
//

import Foundation
struct PaginatedResult<T: Decodable>: Decodable {
    let items: [T]
    let totalCount: Int
    let page: Int
    let totalPages: Int
}
