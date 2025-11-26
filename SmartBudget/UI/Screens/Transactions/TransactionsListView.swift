import SwiftUI

struct TransactionsListView: View {
    @StateObject private var viewModel = TransactionsViewModel()
    @State private var showAddTransaction = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundDark.ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .purplePrimary))
                } else {
                    if viewModel.transactions.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "list.bullet.rectangle.portrait")
                                .font(.system(size: 64))
                                .foregroundColor(.textSecondary)
                            Text("No transactions yet")
                                .font(.title3)
                                .foregroundColor(.textSecondary)
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.transactions) { transaction in
                                    TransactionRow(transaction: transaction)
                                }
                            }
                            .padding()
                        }
                        .refreshable {
                            await viewModel.loadTransactions()
                        }
                    }
                }
            }
            .navigationTitle("Transactions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddTransaction = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(.purplePrimary)
                    }
                }
            }
            .sheet(isPresented: $showAddTransaction) {
                AddTransactionView()
            }
            .onAppear {
                Task {
                    await viewModel.loadTransactions()
                }
            }
        }
    }
}
