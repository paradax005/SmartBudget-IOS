import SwiftUI

struct AddTransactionView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = TransactionsViewModel()
    
    @State private var amount = ""
    @State private var description = ""
    @State private var date = Date()
    @State private var type = "expense"
    @State private var selectedAccountId = ""
    @State private var selectedCategoryId = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Type Toggle
                        HStack(spacing: 0) {
                            Button(action: { type = "expense" }) {
                                Text("Expense")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(type == "expense" ? Color.errorRed : Color.clear)
                                    .foregroundColor(.white)
                            }
                            
                            Button(action: { type = "income" }) {
                                Text("Income")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(type == "income" ? Color.successGreen : Color.clear)
                                    .foregroundColor(.white)
                            }
                        }
                        .background(Color.surfaceDark)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // Amount Input
                        VStack(spacing: 8) {
                            Text("Amount")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                            
                            TextField("0.00", text: $amount)
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(type == "expense" ? .errorRed : .successGreen)
                                .multilineTextAlignment(.center)
                                .keyboardType(.decimalPad)
                        }
                        
                        // Form Fields
                        VStack(spacing: 16) {
                            // Description
                            TextField("Description", text: $description)
                                .padding()
                                .background(Color.surfaceDark)
                                .cornerRadius(12)
                                .foregroundColor(.white)
                            
                            // Date
                            DatePicker("Date", selection: $date, displayedComponents: .date)
                                .padding()
                                .background(Color.surfaceDark)
                                .cornerRadius(12)
                                .colorScheme(.dark)
                            
                            // Account Picker
                            Menu {
                                ForEach(viewModel.accounts) { account in
                                    Button(action: { selectedAccountId = account.id }) {
                                        Text(account.name)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text("Account")
                                        .foregroundColor(.textSecondary)
                                    Spacer()
                                    Text(viewModel.accounts.first(where: { $0.id == selectedAccountId })?.name ?? "Select Account")
                                        .foregroundColor(selectedAccountId.isEmpty ? .textSecondary : .white)
                                }
                                .padding()
                                .background(Color.surfaceDark)
                                .cornerRadius(12)
                            }
                            
                            // Category Picker
                            Menu {
                                ForEach(viewModel.categories.filter { $0.type == type }) { category in
                                    Button(action: { selectedCategoryId = category.id }) {
                                        HStack {
                                            Text(category.icon ?? "")
                                            Text(category.name)
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text("Category")
                                        .foregroundColor(.textSecondary)
                                    Spacer()
                                    if let category = viewModel.categories.first(where: { $0.id == selectedCategoryId }) {
                                        HStack {
                                            Text(category.icon ?? "")
                                            Text(category.name)
                                        }
                                        .foregroundColor(.white)
                                    } else {
                                        Text("Select Category")
                                            .foregroundColor(.textSecondary)
                                    }
                                }
                                .padding()
                                .background(Color.surfaceDark)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                        
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.errorRed)
                                .font(.caption)
                        }
                        
                        Button(action: {
                            Task {
                                let success = await viewModel.addTransaction(
                                    amount: Double(amount) ?? 0.0,
                                    description: description,
                                    date: date,
                                    type: type,
                                    accountId: selectedAccountId,
                                    categoryId: selectedCategoryId
                                )
                                if success {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Save Transaction")
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding()
                        .background(Color.purplePrimary)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        .disabled(amount.isEmpty || selectedAccountId.isEmpty || selectedCategoryId.isEmpty)
                        .opacity((amount.isEmpty || selectedAccountId.isEmpty || selectedCategoryId.isEmpty) ? 0.5 : 1.0)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .onAppear {
                Task {
                    await viewModel.loadDependencies()
                    // Set default account if available
                    if let firstAccount = viewModel.accounts.first {
                        selectedAccountId = firstAccount.id
                    }
                }
            }
        }
    }
}
