import SwiftUI

@MainActor
class AccountsViewModel: ObservableObject {
    @Published var accounts: [Account] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadAccounts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await APIService.shared.getAccounts()
            accounts = response.data
        } catch let error as APIError {
            switch error {
            case .serverError(let message):
                errorMessage = message
            default:
                errorMessage = "Failed to load accounts"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func createAccount(name: String, type: String, balance: Double, currency: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = CreateAccountRequest(
                name: name,
                type: type,
                balance: balance,
                currency: currency
            )
            _ = try await APIService.shared.createAccount(request: request)
            // Reload accounts list
            await loadAccounts()
            isLoading = false
            return true
        } catch let error as APIError {
            switch error {
            case .serverError(let message):
                errorMessage = message
            default:
                errorMessage = "Failed to create account"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
        return false
    }
}
