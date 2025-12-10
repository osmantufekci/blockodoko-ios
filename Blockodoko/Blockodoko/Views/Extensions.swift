import SwiftUI

extension Color {
    static let themeBackground = Color(hex: "121212")
    static let themeBoard = Color(hex: "1a1a1a")
    static let themeTray = Color(hex: "1e1e1e")
    
    // Palette from JS
    static let c0 = Color(hex: "FF5252") // Red
    static let c1 = Color(hex: "448AFF") // Blue
    static let c2 = Color(hex: "69F0AE") // Green
    static let c3 = Color(hex: "E040FB") // Puple
    static let c4 = Color(hex: "FFD740") // Yellow
    static let c5 = Color(hex: "FF6E40") // Orange
    static let prefill = Color.white.opacity(0.15)
    
    static func from(string: String) -> Color {
        switch string {
        case "c-0": return .c0
        case "c-1": return .c1
        case "c-2": return .c2
        case "c-3": return .c3
        case "c-4": return .c4
        case "c-5": return .c5
        case "c-god": return .purple // Gradient handled separately if needed
        case "prefill_gray": return .prefill
        default: return .gray
        }
    }
}

extension Color {
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
