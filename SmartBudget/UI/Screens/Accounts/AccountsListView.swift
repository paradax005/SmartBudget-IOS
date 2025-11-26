import SwiftUI

struct AccountsListView: View {
    @StateObject private var viewModel = AccountsViewModel()
    @State private var showAddAccount = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundDark.ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .purplePrimary))
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.accounts) { account in
                                AccountRow(account: account)
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.loadAccounts()
                    }
                }
            }
            .navigationTitle("Accounts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddAccount = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(.purplePrimary)
                    }
                }
            }
            .sheet(isPresented: $showAddAccount) {
                AddAccountView(viewModel: viewModel)
            }
            .onAppear {
                Task {
                    await viewModel.loadAccounts()
                }
            }
        }
    }
}


