import SwiftUI

struct AddAccountView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: AccountsViewModel
    
    @State private var name = ""
    @State private var type = "checking"
    @State private var balance = ""
    @State private var currency = "USD"
    
    let accountTypes = ["checking", "savings", "credit", "cash"]
    let currencies = ["USD", "EUR", "GBP", "JPY", "CAD", "AUD"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Form Fields
                        VStack(spacing: 16) {
                            // Account Name
                            TextField("Account Name", text: $name)
                                .padding()
                                .background(Color.surfaceDark)
                                .cornerRadius(12)
                                .foregroundColor(.white)
                            
                            // Account Type
                            Menu {
                                ForEach(accountTypes, id: \.self) { accountType in
                                    Button(action: { type = accountType }) {
                                        Text(accountType.capitalized)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text("Type")
                                        .foregroundColor(.textSecondary)
                                    Spacer()
                                    Text(type.capitalized)
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(Color.surfaceDark)
                                .cornerRadius(12)
                            }
                            
                            // Initial Balance
                            VStack(spacing: 8) {
                                Text("Initial Balance")
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                                
                                TextField("0.00", text: $balance)
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.purplePrimary)
                                    .multilineTextAlignment(.center)
                                    .keyboardType(.decimalPad)
                            }
                            
                            // Currency
                            Menu {
                                ForEach(currencies, id: \.self) { curr in
                                    Button(action: { currency = curr }) {
                                        Text(curr)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text("Currency")
                                        .foregroundColor(.textSecondary)
                                    Spacer()
                                    Text(currency)
                                        .foregroundColor(.white)
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
                                let success = await viewModel.createAccount(
                                    name: name,
                                    type: type,
                                    balance: Double(balance) ?? 0.0,
                                    currency: currency
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
                                Text("Create Account")
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding()
                        .background(Color.purplePrimary)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        .disabled(name.isEmpty || balance.isEmpty)
                        .opacity((name.isEmpty || balance.isEmpty) ? 0.5 : 1.0)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Add Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}
