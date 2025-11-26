import SwiftUI
import Charts

struct AnalyticsView: View {
    @StateObject private var viewModel = AnalyticsViewModel()
    
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
                            // Month Selector (Simplified)
                            HStack {
                                Text("\(Calendar.current.monthSymbols[viewModel.selectedMonth - 1]) \(String(viewModel.selectedYear))")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Spacer()
                                // Add chevron buttons to change month here
                            }
                            .padding(.horizontal)
                            
                            if let stats = viewModel.monthlyStats {
                                // Overview Cards
                                HStack(spacing: 12) {
                                    AnalyticsCard(title: "Income", amount: stats.totalIncome, color: .successGreen)
                                    AnalyticsCard(title: "Expense", amount: stats.totalExpense, color: .errorRed)
                                }
                                .padding(.horizontal)
                                
                                // Spending Breakdown Chart
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Spending by Category")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    if let expenses = stats.byCategory?.expense, !expenses.isEmpty {
                                        Chart(expenses) { item in
                                            SectorMark(
                                                angle: .value("Amount", item.total),
                                                innerRadius: .ratio(0.6),
                                                angularInset: 1.5
                                            )
                                            .cornerRadius(5)
                                            .foregroundStyle(by: .value("Category", item.categoryName ?? "Unknown"))
                                        }
                                        .frame(height: 250)
                                        .padding()
                                    } else {
                                        Text("No expense data")
                                            .foregroundColor(.textSecondary)
                                            .frame(height: 200)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                .padding()
                                .background(Color.surfaceDark)
                                .cornerRadius(24)
                                .padding(.horizontal)
                                
                                // Category List
                                if let expenses = stats.byCategory?.expense {
                                    VStack(spacing: 16) {
                                        ForEach(expenses) { item in
                                            HStack {
                                                Circle()
                                                    .fill(Color.purplePrimary) // Should match chart color
                                                    .frame(width: 12, height: 12)
                                                Text(item.categoryName ?? "Unknown")
                                                    .foregroundColor(.white)
                                                Spacer()
                                                Text(item.total.formattedCurrency)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(Color.surfaceDark)
                                    .cornerRadius(24)
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    .refreshable {
                        await viewModel.loadStats()
                    }
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                Task {
                    await viewModel.loadStats()
                }
            }
        }
    }
}

struct AnalyticsCard: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
            Text(amount.formattedCurrency)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.surfaceDark)
        .cornerRadius(16)
    }
}
