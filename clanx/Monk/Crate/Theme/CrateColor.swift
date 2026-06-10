import SwiftUI

// Gradient background colors that make glass visible
enum CrateColor {
    static let background = Color.black
    static let surface = Color(white: 0.11)
    static let surfaceElevated = Color(white: 0.17)
    static let primaryText = Color.white
    static let secondaryText = Color(white: 0.62)
    static let accent = Color.white

    // Subtle gradient behind glass so it's visible even on dark screens
    static let glassBackground = LinearGradient(
        colors: [
            Color(red: 0.08, green: 0.08, blue: 0.14),
            Color(red: 0.05, green: 0.05, blue: 0.10)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func gradient(for seed: String) -> LinearGradient {
        let hue = Double(abs(seed.hashValue) % 360) / 360
        let top = Color(hue: hue, saturation: 0.45, brightness: 0.5)
        let bottom = Color(hue: (hue + 0.08).truncatingRemainder(dividingBy: 1), saturation: 0.55, brightness: 0.28)
        return LinearGradient(colors: [top, bottom], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
