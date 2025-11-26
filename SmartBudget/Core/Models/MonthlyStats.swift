import Foundation

struct MonthlyStatsContainer: Codable {
    let data: MonthlyStatsDto
    let message: String?
}

struct MonthlyStatsDto: Codable {
    let month: Int
    let year: Int
    let totalIncome: Double
    let totalExpense: Double
    let netAmount: Double
    let incomeCount: Int?
    let expenseCount: Int?
    let byCategory: ByCategoryDto?
}

struct ByCategoryDto: Codable {
    let income: [CategoryStatsDto]?
    let expense: [CategoryStatsDto]?
}

struct CategoryStatsDto: Codable, Identifiable {
    let categoryId: String
    let categoryName: String?
    let total: Double
    let count: Int?
    
    var id: String { categoryId }
}
