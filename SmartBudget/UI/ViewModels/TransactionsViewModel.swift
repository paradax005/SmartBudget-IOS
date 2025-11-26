import SwiftUI

@MainActor
class TransactionsViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // For Add Transaction
    @Published var accounts: [Account] = []
    @Published var categories: [Category] = []
    
    func loadTransactions() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await APIService.shared.getTransactions()
            transactions = response.data
        } catch let error as APIError {
            switch error {
            case .serverError(let message):
                errorMessage = message
            default:
                errorMessage = "Failed to load transactions"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func loadDependencies() async {
        do {
            async let accountsResponse = APIService.shared.getAccounts()
            async let categoriesResponse = APIService.shared.getCategories()
            
            accounts = try await accountsResponse.data
            categories = try await categoriesResponse.data
        } catch {
            print("Error loading dependencies: \(error)")
            errorMessage = "Failed to load accounts and categories"
        }
    }
    
    func addTransaction(amount: Double, description: String, date: Date, type: String, accountId: String, categoryId: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let dateString = formatter.string(from: date)
        
        do {
            let request = CreateTransactionRequest(
                amount: amount,
                description: description,
                date: dateString,
                type: type,
                accountId: accountId,
                categoryId: categoryId
            )
            _ = try await APIService.shared.createTransaction(request: request)
            // Reload transactions list
            await loadTransactions()
            isLoading = false
            return true
        } catch let error as APIError {
            switch error {
            case .serverError(let message):
                errorMessage = message
            default:
                errorMessage = "Failed to create transaction"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
        return false
    }
}
