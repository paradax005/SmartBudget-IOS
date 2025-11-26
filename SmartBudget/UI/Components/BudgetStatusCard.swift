import SwiftUI

struct BudgetStatusCard: View {
    let status: BudgetStatusResponse
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Budget Status")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                if let count = status.alertCount, count > 0 {
                    Text("\(count) exceeded")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.errorRed)
                }
            }
            
            // We could add total budgeted vs spent here if available in response
            // For now just showing the list below
        }
        .padding()
        .background(Color.surfaceDark)
        .cornerRadius(24)
    }
}
