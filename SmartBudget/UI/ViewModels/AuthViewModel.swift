import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUser: User?
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        isAuthenticated = TokenManager.shared.isAuthenticated
    }
    
    func login(email: String, password: String) async {
        print("🔵 Login attempt - Email: \(email), Password length: \(password.count)")
        isLoading = true
        errorMessage = nil
        
        do {
            let request = LoginRequest(email: email, password: password)
            print("🔵 Sending login request...")
            let response = try await APIService.shared.login(request: request)
            print("✅ Login successful - Token: \(response.token.prefix(10))...")
            TokenManager.shared.saveToken(response.token)
            currentUser = response.user
            isAuthenticated = true
        } catch let error as APIError {
            print("❌ API Error: \(error)")
            switch error {
            case .serverError(let message):
                print("❌ Server error: \(message)")
                errorMessage = message
            case .unauthorized:
                errorMessage = "Invalid credentials"
            default:
                errorMessage = "An error occurred. Please try again."
            }
        } catch {
            print("❌ Unknown error: \(error)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
        print("🔵 Login completed - Error: \(errorMessage ?? "none")")
    }
    
    func register(fullName: String, email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = RegisterRequest(email: email, password: password, fullName: fullName)
            let response = try await APIService.shared.register(request: request)
            TokenManager.shared.saveToken(response.token)
            currentUser = response.user
            isAuthenticated = true
        } catch let error as APIError {
            switch error {
            case .serverError(let message):
                errorMessage = message
            default:
                errorMessage = "Registration failed. Please try again."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func logout() {
        TokenManager.shared.clearToken()
        isAuthenticated = false
        currentUser = nil
    }
}
