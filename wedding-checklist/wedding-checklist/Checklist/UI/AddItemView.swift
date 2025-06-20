//
//  AddItemView.swift
//  wedding-checklist
//
//  Created by Alex Shillingford on 6/19/25.
//

import SwiftUI

struct AddItemView: View {
    @ObservedObject var viewModel: ChecklistViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory: String?
    @State private var selectedPriority = 3
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @State private var isLoading = false
    
    private let categories = ["Venue", "Catering", "Photography", "Flowers", "Music", "Attire", "Guests", "Other"]
    private let priorities = [
        (1, "High", Color.red),
        (2, "Medium", Color.orange),
        (3, "Normal", Color.blue),
        (4, "Low", Color.gray)
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...5)
                }
                
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        Text("None").tag(nil as String?)
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category as String?)
                        }
                    }
                }
                
                Section("Priority") {
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(priorities, id: \.0) { priority in
                            Label(priority.1, systemImage: "flag.fill")
                                .foregroundColor(priority.2)
                                .tag(priority.0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("Due Date") {
                    Toggle("Set due date", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker(
                            "Due date",
                            selection: $dueDate,
                            displayedComponents: [.date]
                        )
                    }
                }
            }
            .navigationTitle("New Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addItem()
                    }
                    .disabled(title.isEmpty || isLoading)
                }
            }
            .disabled(isLoading)
            .overlay {
                if isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView()
                }
            }
        }
    }
    
    private func addItem() {
        isLoading = true
        
        Task {
            await viewModel.createItem(
                title: title,
                description: description.isEmpty ? nil : description,
                category: selectedCategory,
                dueDate: hasDueDate ? dueDate : nil,
                priority: selectedPriority
            )
            
            await MainActor.run {
                dismiss()
            }
        }
    }
}

//#Preview {
//    AddItemView()
//}
