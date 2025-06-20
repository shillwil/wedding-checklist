//
//  Config.swift
//  wedding-checklist
//
//  Created by Alex Shillingford on 6/14/25.
//

import Foundation

enum Config {
    static let apiBaseURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as! String
}
