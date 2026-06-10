import SwiftUI

// Convenience wrapper — app targets iOS 26+, glassEffect is always available
extension View {
    func crateGlass<S: Shape>(_ shape: S) -> some View {
        glassEffect(.regular, in: shape)
    }
}
