import Foundation

struct User: Codable, Identifiable {
    let id: String
    let fullName: String
    let email: String
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case _id
        case fullName
        case email
        case createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try to decode id, fallback to _id
        if let idValue = try? container.decode(String.self, forKey: .id) {
            self.id = idValue
        } else if let idValue = try? container.decode(String.self, forKey: ._id) {
            self.id = idValue
        } else {
            throw DecodingError.keyNotFound(CodingKeys.id, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Neither 'id' nor '_id' found"))
        }
        
        self.fullName = try container.decode(String.self, forKey: .fullName)
        self.email = try container.decode(String.self, forKey: .email)
        self.createdAt = try? container.decode(String.self, forKey: .createdAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(fullName, forKey: .fullName)
        try container.encode(email, forKey: .email)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
    }
}

struct AuthResponse: Codable {
    let message: String
    let token: String
    let user: User
}

typealias LoginResponse = AuthResponse
typealias RegisterResponse = AuthResponse
