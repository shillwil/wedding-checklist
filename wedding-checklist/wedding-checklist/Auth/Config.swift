//
//  Config.swift
//  wedding-checklist
//
//  Created by Alex Shillingford on 6/14/25.
//

import Foundation

enum Config {
    static let apiBaseURL: String = {
            // This reads from Xcode scheme environment variables
            if let urlString = ProcessInfo.processInfo.environment["API_BASE_URL"] {
                return urlString
            }
            
            // Fallback for production/release builds
            return ""
        }()
}
