import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.surfaceDark)
                    .frame(width: 40, height: 40)
                Text(transaction.category?.icon ?? "📄")
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category?.name ?? transaction.description ?? "Transaction")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(transaction.date.prefix(10)) // Simple date formatting
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Text((transaction.type == "expense" ? "-" : "+") + transaction.amount.formattedCurrency)
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(transaction.type == "expense" ? .errorRed : .successGreen)
        }
        .padding()
        .background(Color.surfaceDark)
        .cornerRadius(16)
    }
}
