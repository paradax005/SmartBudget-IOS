import SwiftUI

extension Color {
    static let purplePrimary = Color(hex: "6C5CE7")
    static let purpleLight = Color(hex: "8B7FF5")
    static let backgroundDark = Color(hex: "0A0E27")
    static let surfaceDark = Color(hex: "1A1F3A")
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "8F92A1")
    static let successGreen = Color(hex: "00D09C")
    static let errorRed = Color(hex: "FF6B6B")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
