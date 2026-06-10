import SwiftUI

// All glass calls go through here — .interactive() for controls, .regular for containers
extension View {
    func crateGlass<S: Shape>(_ shape: S) -> some View {
        glassEffect(.regular, in: shape)
    }

    func crateGlassInteractive<S: Shape>(_ shape: S) -> some View {
        glassEffect(.regular.interactive(), in: shape)
    }
}
