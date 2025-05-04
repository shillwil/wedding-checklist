//
//  ChecklistQueryParams.swift
//  wedding-checklist
//
//  Created by Alex Shillingford on 5/3/25.
//

import Foundation
struct ChecklistQueryParams: Encodable {
    let page_number: Int
    let items_per_page: Int
    var filter_category: String?
    var search_term: String?
    let sort_field: String
    let sort_direction: String
}
