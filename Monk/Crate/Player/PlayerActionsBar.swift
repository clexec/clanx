import SwiftUI

struct PlayerActionsBar: View {
    let isLiked: Bool
    let onLike: () -> Void
    let onComments: () -> Void

    var body: some View {
        HStack {
            icon(isLiked ? "heart.fill" : "heart", action: onLike)
            Spacer()
            icon("bubble.left", action: onComments)
            Spacer()
            icon("airplayaudio") {}
            Spacer()
            icon("forward.end.fill") {}
            Spacer()
            icon("ellipsis") {}
        }
        .foregroundStyle(CrateColor.secondaryText)
    }

    private func icon(_ name: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: name).font(.system(size: 20, weight: .regular))
        }
        .buttonStyle(.plain)
    }
}
