import SwiftUI

extension View {
    @ViewBuilder
    func crateGlass<S: Shape>(_ shape: S) -> some View {
        if #available(iOS 26.0, *) {
            glassEffect(.regular, in: shape)
        } else {
            background(.ultraThinMaterial, in: shape)
        }
    }
}
