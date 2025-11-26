import SwiftUI

struct BudgetRow: View {
    let budget: Budget
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(budget.category?.icon ?? "💰")
                Text(budget.category?.name ?? "Category")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text(budget.amount.formattedCurrency)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
            
            // Progress bar calculation
            let spent = budget.spent ?? 0.0
            let progress = budget.amount > 0 ? spent / budget.amount : 0
            
            ProgressView(value: spent, total: budget.amount)
                .accentColor(progress > 1.0 ? .errorRed : .successGreen)
            
            HStack {
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundColor(progress > 1.0 ? .errorRed : .successGreen)
                Spacer()
                Text("Spent: \(spent.formattedCurrency)")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding()
        .background(Color.surfaceDark)
        .cornerRadius(16)
    }
}
