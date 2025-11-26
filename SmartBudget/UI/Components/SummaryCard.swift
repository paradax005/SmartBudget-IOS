import SwiftUI

struct SummaryCard: View {
    let income: Double
    let expense: Double
    let net: Double
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 0) {
                // Income
                VStack(spacing: 4) {
                    Text("Total Income")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    Text(income.formattedCurrency)
                        .font(.headline)
                        .foregroundColor(.successGreen)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .background(Color.textSecondary.opacity(0.2))
                    .frame(height: 40)
                
                // Expense
                VStack(spacing: 4) {
                    Text("Total Expenses")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    Text(expense.formattedCurrency)
                        .font(.headline)
                        .foregroundColor(.errorRed)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .background(Color.textSecondary.opacity(0.2))
                    .frame(height: 40)
                
                // Net
                VStack(spacing: 4) {
                    Text("Net Amount")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    Text(net.formattedCurrency)
                        .font(.headline)
                        .foregroundColor(.purpleLight)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color.surfaceDark)
        .cornerRadius(24)
    }
}

extension Double {
    var formattedCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD" // Or dynamic based on user settings
        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }
}
