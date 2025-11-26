import Foundation

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case serverError(String)
    case unauthorized
}

class APIService {
    static let shared = APIService()
    private let baseURL = "http://127.0.0.1:3000/api"
    
    private init() {}
    
    // MARK: - Generic Request
    private func request<T: Decodable>(_ endpoint: String, method: String = "GET", body: Data? = nil) async throws -> T {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            if httpResponse.statusCode == 401 {
                TokenManager.shared.clearToken()
                throw APIError.unauthorized
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                // Try to parse error message
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw APIError.serverError(errorResponse.error)
                }
                throw APIError.serverError("Server returned \(httpResponse.statusCode)")
            }
            
            let decoder = JSONDecoder()
            // Handle date decoding if needed, or use String for dates as in models
            
            return try decoder.decode(T.self, from: data)
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - Auth
    func login(request: LoginRequest) async throws -> LoginResponse {
        let body = try JSONEncoder().encode(request)
        return try await self.request("auth/login", method: "POST", body: body)
    }
    
    func register(request: RegisterRequest) async throws -> RegisterResponse {
        let body = try JSONEncoder().encode(request)
        return try await self.request("auth/register", method: "POST", body: body)
    }
    
    // MARK: - Transactions
    func getTransactions() async throws -> TransactionsResponse {
        return try await self.request("transactions")
    }
    
    // MARK: - Budgets
    func getBudgets(month: Int, year: Int) async throws -> BudgetsResponse {
        return try await self.request("budgets?month=\(month)&year=\(year)")
    }
    
    func getBudgetStatus(month: Int, year: Int) async throws -> BudgetStatusResponse {
        return try await self.request("budgets/status?month=\(month)&year=\(year)")
    }
    
    // MARK: - Accounts
    func getAccounts() async throws -> AccountsResponse {
        return try await self.request("accounts")
    }
    
    // MARK: - Analytics
    func getMonthlyStats(month: Int, year: Int) async throws -> MonthlyStatsContainer {
        return try await self.request("transactions/stats/monthly?month=\(month)&year=\(year)")
    }
    
    // MARK: - Categories
    func getCategories() async throws -> CategoriesResponse {
        return try await self.request("categories")
    }
    
    func createCategory(request: CreateCategoryRequest) async throws -> Category {
        let body = try JSONEncoder().encode(request)
        return try await self.request("categories", method: "POST", body: body)
    }
    
    func deleteCategory(id: String) async throws {
        let _: EmptyResponse = try await self.request("categories/\(id)", method: "DELETE")
    }
    
    // MARK: - Create Transaction
    func createTransaction(request: CreateTransactionRequest) async throws -> Transaction {
        let body = try JSONEncoder().encode(request)
        return try await self.request("transactions", method: "POST", body: body)
    }
    
    // MARK: - Create Budget
    func createBudget(request: CreateBudgetRequest) async throws -> Budget {
        let body = try JSONEncoder().encode(request)
        return try await self.request("budgets", method: "POST", body: body)
    }
    
    // MARK: - Create Account
    func createAccount(request: CreateAccountRequest) async throws -> Account {
        let body = try JSONEncoder().encode(request)
        return try await self.request("accounts", method: "POST", body: body)
    }
}

struct ErrorResponse: Codable {
    let error: String
    let status: Int
}

// Request Models
struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let fullName: String
}

struct CreateTransactionRequest: Codable {
    let amount: Double
    let description: String
    let date: String
    let type: String
    let accountId: String
    let categoryId: String
}

struct CreateBudgetRequest: Codable {
    let amount: Double
    let categoryId: String
    let month: Int
    let year: Int
}

struct CreateAccountRequest: Codable {
    let name: String
    let type: String
    let balance: Double
    let currency: String
}

struct CreateCategoryRequest: Codable {
    let name: String
    let type: String
    let icon: String
    let color: String
}

struct EmptyResponse: Codable {
    // Used for DELETE requests that return no content
}
