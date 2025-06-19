//
//  ChecklistView.swift
//  wedding-checklist
//
//  Created by Alex Shillingford on 4/25/25.
//

import SwiftUI
import Supabase

struct ChecklistView: View {
    @StateObject var viewModel = ChecklistViewModel(service: ChecklistService())
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                TextField("Search checklist", text: $searchText)
                    .padding(7)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .onChange(of: searchText) { newValue in
                        viewModel.searchTerm = newValue
                        Task {
                            await viewModel.loadItems(resetPage: true)
                        }
                    }
                
                // Category filters (horizontal scrolling)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        CategoryButton(title: "All", isSelected: viewModel.selectedCategory == nil) {
                            viewModel.selectedCategory = nil
                            Task {
                                await viewModel.loadItems(resetPage: true)
                            }
                        }
                        
                        // Add your category buttons here
                        // Example:
                        CategoryButton(title: "Venue", isSelected: viewModel.selectedCategory == "Venue") {
                            viewModel.selectedCategory = "Venue"
                            Task {
                                await viewModel.loadItems(resetPage: true)
                            }
                        }
                        // More categories...
                    }
                    .padding(.horizontal)
                }
                
                // Checklist items
                List {
                    ForEach(viewModel.items) { item in
                        ChecklistItemRow(item: item)
                    }
                    
                    // Loading indicator for next page
                    if viewModel.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else if viewModel.currentPage < viewModel.totalPages {
                        Button("Load More") {
                            Task {
                                await viewModel.loadNextPage()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                
                // Pagination controls
                HStack {
                    Button(action: {
                        Task {
                            await viewModel.loadPreviousPage()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                    }
                    .disabled(viewModel.currentPage == 1)
                    
                    Text("Page \(viewModel.currentPage) of \(viewModel.totalPages)")
                    
                    Button(action: {
                        Task {
                            await viewModel.loadNextPage()
                        }
                    }) {
                        Image(systemName: "chevron.right")
                    }
                    .disabled(viewModel.currentPage == viewModel.totalPages)
                }
                .padding()
            }
            .navigationTitle("Wedding Checklist")
            .onAppear {
                Task {
                    await viewModel.loadItems()
                }
            }
        }
    }
}

//#Preview {
//    ChecklistView()
//}
