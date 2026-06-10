import SwiftUI

// Unified glass helpers — matches Mono's .glassEffect(in:) API
extension View {
    func crateGlass<S: Shape>(_ shape: S) -> some View {
        #if compiler(>=6.2)
        glassEffect(in: shape)
        #else
        background(.ultraThinMaterial, in: shape)
        #endif
    }

    func crateGlassInteractive<S: Shape>(_ shape: S) -> some View {
        #if compiler(>=6.2)
        glassEffect(.regular.interactive(), in: shape)
        #else
        background(.ultraThinMaterial, in: shape)
        #endif
    }
}
