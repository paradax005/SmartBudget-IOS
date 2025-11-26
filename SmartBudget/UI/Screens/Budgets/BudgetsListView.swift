import SwiftUI

struct BudgetsListView: View {
    @StateObject private var viewModel = BudgetsViewModel()
    @State private var showAddBudget = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundDark.ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .purplePrimary))
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Status Summary
                            if let status = viewModel.budgetStatus {
                                BudgetStatusCard(status: status)
                                    .padding(.horizontal)
                            }
                            
                            // Budgets List
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.budgets) { budget in
                                    BudgetRow(budget: budget)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                    .refreshable {
                        await viewModel.loadBudgets()
                    }
                }
            }
            .navigationTitle("Budgets")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddBudget = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(.purplePrimary)
                    }
                }
            }
            .sheet(isPresented: $showAddBudget) {
                AddBudgetView(viewModel: viewModel)
            }
            .onAppear {
                Task {
                    await viewModel.loadBudgets()
                }
            }
        }
    }
}


