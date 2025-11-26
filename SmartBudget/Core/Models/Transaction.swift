import Foundation

struct Transaction: Codable, Identifiable {
    let id: String
    let amount: Double
    let description: String?
    let date: String
    let type: String // "income" or "expense"
    let accountId: String?
    let categoryId: String?
    let account: Account?
    let category: Category?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case amount
        case description
        case date
        case type
        case accountId
        case categoryId
        case account
        case category
        case createdAt
    }
    
    // Helper to get display category
    var displayCategory: Category? {
        return category
    }
    
    // Helper to get display account
    var displayAccount: Account? {
        return account
    }
}

struct TransactionsResponse: Codable {
    let data: [Transaction]
    let count: Int?
    let message: String?
}
