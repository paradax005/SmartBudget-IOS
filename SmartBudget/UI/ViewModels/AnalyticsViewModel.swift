import SwiftUI

@MainActor
class AnalyticsViewModel: ObservableObject {
    @Published var monthlyStats: MonthlyStatsDto?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Selected period
    @Published var selectedMonth: Int
    @Published var selectedYear: Int
    
    init() {
        let calendar = Calendar.current
        self.selectedMonth = calendar.component(.month, from: Date())
        self.selectedYear = calendar.component(.year, from: Date())
    }
    
    func loadStats() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let container = try await APIService.shared.getMonthlyStats(month: selectedMonth, year: selectedYear)
            monthlyStats = container.data
        } catch let error as APIError {
            switch error {
            case .serverError(let message):
                errorMessage = message
            default:
                errorMessage = "Failed to load analytics"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
