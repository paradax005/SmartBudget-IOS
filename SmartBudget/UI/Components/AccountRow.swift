import SwiftUI

struct AccountRow: View {
    let account: Account
    
    var body: some View {
        HStack {
            // Icon based on type
            ZStack {
                Circle()
                    .fill(Color.surfaceDark.opacity(0.5)) // Darker background
                    .frame(width: 48, height: 48)
                
                Image(systemName: getIconForType(account.type))
                    .foregroundColor(getColorForType(account.type))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(account.name)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(account.type.capitalized)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Text(account.balance.formattedCurrency)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.successGreen)
        }
        .padding()
        .background(Color.surfaceDark)
        .cornerRadius(20)
    }
    
    func getIconForType(_ type: String) -> String {
        switch type.lowercased() {
        case "bank": return "building.columns.fill"
        case "cash": return "banknote.fill"
        case "credit_card": return "creditcard.fill"
        case "savings": return "leaf.fill"
        default: return "creditcard"
        }
    }
    
    func getColorForType(_ type: String) -> Color {
        switch type.lowercased() {
        case "bank": return .blue
        case "cash": return .orange
        case "credit_card": return .purple
        case "savings": return .green
        default: return .gray
        }
    }
}
