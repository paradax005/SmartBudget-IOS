import Foundation

struct Category: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let type: String // "income" or "expense"
    let icon: String?
    let color: String?
    let isDefault: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case type
        case icon
        case color
        case isDefault
    }
}

struct CategoriesResponse: Codable {
    let data: [Category]
    let count: Int?
    let message: String?
}
