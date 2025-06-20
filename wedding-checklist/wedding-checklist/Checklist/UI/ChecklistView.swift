//
//  ChecklistView.swift
//  wedding-checklist
//
//  Created by Alex Shillingford on 4/25/25.
//

import SwiftUI

struct ChecklistView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel: ChecklistViewModel
    @State private var showAddItem = false
    @State private var searchText = ""
    
    init(authService: AuthService) {
        let service = ChecklistService(authService: authService)
        _viewModel = StateObject(wrappedValue: ChecklistViewModel(service: service))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                SearchBar(text: $searchText)
                    .onChange(of: searchText) { _, newValue in
                        viewModel.searchItems(newValue)
                    }
                
                // Category filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        CategoryButton(
                            title: "All",
                            isSelected: viewModel.selectedCategory == nil
                        ) {
                            viewModel.selectedCategory = nil
                            Task { await viewModel.loadItems(resetPage: true) }
                        }
                        
                        ForEach(categories, id: \.self) { category in
                            CategoryButton(
                                title: category,
                                isSelected: viewModel.selectedCategory == category
                            ) {
                                viewModel.selectedCategory = category
                                Task { await viewModel.loadItems(resetPage: true) }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                
                // Checklist items
                if viewModel.isLoading && viewModel.items.isEmpty {
                    Spacer()
                    ProgressView("Loading...")
                    Spacer()
                } else if viewModel.items.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        ForEach(viewModel.items) { item in
                            ChecklistItemRow(
                                item: item,
                                onToggle: {
                                    Task { await viewModel.toggleItemCompletion(item) }
                                },
                                onDelete: {
                                    Task { await viewModel.deleteItem(item) }
                                }
                            )
                        }
                        
                        // Load more button
                        if viewModel.currentPage < viewModel.totalPages {
                            HStack {
                                Spacer()
                                if viewModel.isLoading {
                                    ProgressView()
                                } else {
                                    Button("Load More") {
                                        Task { await viewModel.loadNextPage() }
                                    }
                                }
                                Spacer()
                            }
                            .padding()
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .navigationTitle("Wedding Checklist")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddItem = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.pink)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: {
                            try? authService.signOut()
                        }) {
                            Label("Sign Out", systemImage: "arrow.right.square")
                        }
                    } label: {
                        Image(systemName: "person.circle")
                            .foregroundColor(.pink)
                    }
                }
            }
            .sheet(isPresented: $showAddItem) {
                AddItemView(viewModel: viewModel)
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
        }
        .task {
            await viewModel.loadItems()
        }
    }
    
    private let categories = ["Venue", "Catering", "Photography", "Flowers", "Music", "Attire", "Guests", "Other"]
}

//#Preview {
//    ChecklistView()
//}
