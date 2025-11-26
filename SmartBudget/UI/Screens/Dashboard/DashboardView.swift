import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
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
                            // Header
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Welcome back,")
                                        .font(.subheadline)
                                        .foregroundColor(.textSecondary)
                                    Text(authViewModel.currentUser?.fullName ?? "User")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                Spacer()
                                Button(action: { authViewModel.logout() }) {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .foregroundColor(.textSecondary)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Summary Card
                            if let stats = viewModel.monthlyStats {
                                SummaryCard(
                                    income: stats.totalIncome,
                                    expense: stats.totalExpense,
                                    net: stats.netAmount
                                )
                                .padding(.horizontal)
                            }
                            
                            // Budget Status
                            if let status = viewModel.budgetStatus {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("Budget Status")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Spacer()
                                        if let count = status.alertCount, count > 0 {
                                            Text("\(count) exceeded")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.errorRed)
                                        }
                                    }
                                    .padding(.horizontal)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(status.budgets) { budget in
                                                BudgetCard(budget: budget)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            
                            // Recent Transactions
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Recent Transactions")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                LazyVStack(spacing: 12) {
                                    ForEach(viewModel.recentTransactions) { transaction in
                                        TransactionRow(transaction: transaction)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                    .refreshable {
                        await viewModel.loadData()
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                Task {
                    await viewModel.loadData()
                }
            }
        }
    }
}

struct BudgetCard: View {
    let budget: BudgetStatusItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(budget.category.icon ?? "💰")
                Text(budget.category.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Spacer()
            }
            
            ProgressView(value: budget.spent, total: budget.amount)
                .accentColor(budget.isExceeded ? .errorRed : .successGreen)
            
            HStack {
                Text(budget.spent.formattedCurrency)
                    .font(.caption)
                    .foregroundColor(budget.isExceeded ? .errorRed : .textSecondary)
                Spacer()
                Text(budget.amount.formattedCurrency)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding()
        .frame(width: 160)
        .background(Color.surfaceDark)
        .cornerRadius(16)
    }
}


