import SwiftUI

struct CategoriesListView: View {
    @StateObject private var viewModel = CategoriesViewModel()
    @State private var showAddCategory = false
    @State private var filterType: String? = nil
    
    var filteredCategories: [Category] {
        if let filter = filterType {
            return viewModel.categories.filter { $0.type == filter }
        }
        return viewModel.categories
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundDark.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Filter Chips
                    HStack(spacing: 12) {
                        FilterChip(title: "All", isSelected: filterType == nil) {
                            filterType = nil
                        }
                        FilterChip(title: "Income", isSelected: filterType == "income") {
                            filterType = "income"
                        }
                        FilterChip(title: "Expense", isSelected: filterType == "expense") {
                            filterType = "expense"
                        }
                    }
                    .padding()
                    
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .purplePrimary))
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredCategories) { category in
                                    CategoryRow(category: category) {
                                        // Delete action
                                        Task {
                                            await viewModel.deleteCategory(id: category.id)
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                        .refreshable {
                            await viewModel.loadCategories()
                        }
                    }
                }
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddCategory = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(.purplePrimary)
                    }
                }
            }
            .sheet(isPresented: $showAddCategory) {
                AddCategoryView(viewModel: viewModel)
            }
            .onAppear {
                Task {
                    await viewModel.loadCategories()
                }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.purplePrimary : Color.surfaceDark)
                .foregroundColor(.white)
                .cornerRadius(20)
        }
    }
}

struct CategoryRow: View {
    let category: Category
    let onDelete: () -> Void
    @State private var showDeleteAlert = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Text(category.icon ?? "📁")
                .font(.system(size: 32))
            
            // Name and Type
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(category.type.capitalized)
                    .font(.caption)
                    .foregroundColor(category.type == "income" ? .successGreen : .errorRed)
            }
            
            Spacer()
            
            // Delete button (only for non-default categories)
            if category.isDefault != true {
                Button(action: { showDeleteAlert = true }) {
                    Image(systemName: "trash")
                        .foregroundColor(.errorRed)
                }
            }
        }
        .padding()
        .background(Color.surfaceDark)
        .cornerRadius(12)
        .alert("Delete Category", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete this category?")
        }
    }
}
