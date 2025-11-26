import SwiftUI

struct AddBudgetView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: BudgetsViewModel
    
    @State private var amount = ""
    @State private var selectedCategoryId = ""
    @State private var month = Calendar.current.component(.month, from: Date())
    @State private var year = Calendar.current.component(.year, from: Date())
    @State private var categories: [Category] = []
    @State private var isLoadingCategories = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Amount Input
                        VStack(spacing: 8) {
                            Text("Budget Amount")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                            
                            TextField("0.00", text: $amount)
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.purplePrimary)
                                .multilineTextAlignment(.center)
                                .keyboardType(.decimalPad)
                        }
                        
                        // Form Fields
                        VStack(spacing: 16) {
                            // Category Picker
                            Menu {
                                ForEach(categories.filter { $0.type == "expense" }) { category in
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
                                    if let category = categories.first(where: { $0.id == selectedCategoryId }) {
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
                            
                            // Month Picker
                            Picker("Month", selection: $month) {
                                ForEach(1...12, id: \.self) { m in
                                    Text(DateFormatter().monthSymbols[m - 1]).tag(m)
                                }
                            }
                            .padding()
                            .background(Color.surfaceDark)
                            .cornerRadius(12)
                            .colorScheme(.dark)
                            
                            // Year Picker
                            Picker("Year", selection: $year) {
                                ForEach(2020...2030, id: \.self) { y in
                                    Text(String(y)).tag(y)
                                }
                            }
                            .padding()
                            .background(Color.surfaceDark)
                            .cornerRadius(12)
                            .colorScheme(.dark)
                        }
                        .padding(.horizontal)
                        
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.errorRed)
                                .font(.caption)
                        }
                        
                        Button(action: {
                            Task {
                                let success = await viewModel.createBudget(
                                    amount: Double(amount) ?? 0.0,
                                    categoryId: selectedCategoryId,
                                    month: month,
                                    year: year
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
                                Text("Create Budget")
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding()
                        .background(Color.purplePrimary)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        .disabled(amount.isEmpty || selectedCategoryId.isEmpty)
                        .opacity((amount.isEmpty || selectedCategoryId.isEmpty) ? 0.5 : 1.0)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Add Budget")
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
                    isLoadingCategories = true
                    do {
                        let response = try await APIService.shared.getCategories()
                        categories = response.data
                    } catch {
                        print("Error loading categories: \(error)")
                    }
                    isLoadingCategories = false
                }
            }
        }
    }
}
