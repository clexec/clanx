import SwiftUI

enum Theme {
    static let background = Color(red: 0.07, green: 0.07, blue: 0.08)
    static let surface = Color(red: 0.12, green: 0.12, blue: 0.13)
    static let surfaceElevated = Color(red: 0.17, green: 0.17, blue: 0.18)
    static let accent = Color(red: 0.114, green: 0.725, blue: 0.329)
    static let accentBright = Color(red: 0.18, green: 0.85, blue: 0.44)
    static let textPrimary = Color.white
    static let textSecondary = Color(white: 0.68)
    static let textTertiary = Color(white: 0.45)

    static let cornerRadius: CGFloat = 12
    static let cardCornerRadius: CGFloat = 8

    static func screenGradient(top: Color) -> LinearGradient {
        LinearGradient(
            colors: [top.opacity(0.55), background, background],
            startPoint: .top,
            endPoint: .center
        )
    }
}


extension Color {
    static func seeded(_ seed: String) -> Color {
        var hash: UInt64 = 5381
        for byte in seed.utf8 {
            hash = (hash &* 33) ^ UInt64(byte)
        }
        let hue = Double(hash % 360) / 360.0
        return Color(hue: hue, saturation: 0.55, brightness: 0.6)
    }
}
