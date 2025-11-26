import SwiftUI

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var monthlyStats: MonthlyStatsDto?
    @Published var recentTransactions: [Transaction] = []
    @Published var budgetStatus: BudgetStatusResponse?
    
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        let calendar = Calendar.current
        let month = calendar.component(.month, from: Date())
        let year = calendar.component(.year, from: Date())
        
        do {
            // Fetch Stats
            let statsContainer = try await APIService.shared.getMonthlyStats(month: month, year: year)
            monthlyStats = statsContainer.data
            
            // Fetch Recent Transactions
            let transactionsResponse = try await APIService.shared.getTransactions()
            recentTransactions = Array(transactionsResponse.data.prefix(5))
            
            // Fetch Budget Status
            budgetStatus = try await APIService.shared.getBudgetStatus(month: month, year: year)
            
        } catch let error as APIError {
            switch error {
            case .serverError(let message):
                errorMessage = message
            default:
                errorMessage = "Failed to load dashboard data"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
