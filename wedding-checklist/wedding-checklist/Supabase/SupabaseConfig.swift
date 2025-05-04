//
//  SupabaseConfig.swift
//  wedding-checklist
//
//  Created by Alex Shillingford on 5/3/25.
//
import Supabase
import Foundation
enum SupabaseConfig {
    static var projectURL: URL {
        guard let urlString = ProcessInfo.processInfo.environment["SUPABASE_URL"],
              let url = URL(string: urlString) else {
            fatalError("Missing SUPABASE_URL environment variable. Set this in your scheme.")
        }
        return url
    }
    
    static var apiKey: String {
        guard let key = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] else {
            fatalError("Missing SUPABASE_KEY environment variable. Set this in your scheme.")
        }
        return key
    }
}
