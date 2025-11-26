import SwiftUI

@MainActor
class BudgetsViewModel: ObservableObject {
    @Published var budgets: [Budget] = []
    @Published var budgetStatus: BudgetStatusResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadBudgets() async {
        isLoading = true
        errorMessage = nil
        
        let calendar = Calendar.current
        let month = calendar.component(.month, from: Date())
        let year = calendar.component(.year, from: Date())
        
        do {
            async let budgetsResponse = APIService.shared.getBudgets(month: month, year: year)
            async let statusResponse = APIService.shared.getBudgetStatus(month: month, year: year)
            
            budgets = try await budgetsResponse.data
            budgetStatus = try await statusResponse
        } catch let error as APIError {
            switch error {
            case .serverError(let message):
                errorMessage = message
            default:
                errorMessage = "Failed to load budgets"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func createBudget(amount: Double, categoryId: String, month: Int, year: Int) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = CreateBudgetRequest(
                amount: amount,
                categoryId: categoryId,
                month: month,
                year: year
            )
            _ = try await APIService.shared.createBudget(request: request)
            // Reload budgets list
            await loadBudgets()
            isLoading = false
            return true
        } catch let error as APIError {
            switch error {
            case .serverError(let message):
                errorMessage = message
            default:
                errorMessage = "Failed to create budget"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
        return false
    }
}
