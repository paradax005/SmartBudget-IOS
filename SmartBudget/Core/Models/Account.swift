import Foundation

struct Account: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let type: String
    let balance: Double
    let currency: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case type
        case balance
        case currency
    }
}

struct AccountsResponse: Codable {
    let data: [Account]
    let count: Int?
    let message: String?
}
