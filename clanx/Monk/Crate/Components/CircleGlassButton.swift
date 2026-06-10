import SwiftUI

struct CircleGlassButton: View {
    let systemName: String
    var size: CGFloat = 64
    var iconScale: CGFloat = 0.4
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: size * iconScale, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: size, height: size)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .crateGlassInteractive(Circle())
        .frame(width: size, height: size)
    }
}
