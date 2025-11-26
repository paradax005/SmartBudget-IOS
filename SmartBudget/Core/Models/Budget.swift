import Foundation

struct Budget: Codable, Identifiable {
    let id: String
    let categoryId: String? // Can be string ID or object in some responses, need custom decoding if mixed
    let category: Category?
    let amount: Double
    let month: Int?
    let year: Int?
    let spent: Double?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case categoryId
        case category
        case amount
        case month
        case year
        case spent
    }
    
    // Custom decoding to handle categoryId being either String or Object (if backend is inconsistent)
    // For now assuming the backend fix (categoryId mapped to Category object) is consistent
    // or we use the `category` field.
}

struct BudgetsResponse: Codable {
    let data: [Budget]
    let count: Int?
    let message: String?
}

struct BudgetStatusResponse: Codable {
    let month: Int
    let year: Int
    let budgets: [BudgetStatusItem]
    let alertCount: Int?
}

struct BudgetStatusItem: Codable, Identifiable {
    let id: String
    let category: Category
    let amount: Double
    let spent: Double
    let remaining: Double
    let percentage: String
    let isExceeded: Bool
}
