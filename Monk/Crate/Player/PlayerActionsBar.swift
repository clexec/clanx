import SwiftUI
import AVKit

struct PlayerActionsBar: View {
    let isLiked: Bool
    let onLike: () -> Void
    let onComments: () -> Void

    @EnvironmentObject private var player: PlayerManager
    @State private var showShare = false
    @State private var likeBounce = false

    var body: some View {
        HStack {
            likeButton
            Spacer()
            actionIcon("bubble.left", action: onComments)
            Spacer()
            AirPlayIcon().frame(width: 36, height: 36)
            Spacer()
            actionIcon("forward.end.fill") {
                player.audio.seek(to: max(0, player.audio.duration - 0.5))
            }
            Spacer()
            actionIcon("square.and.arrow.up") { showShare = true }
        }
        .sheet(isPresented: $showShare) {
            if let track = player.currentTrack {
                ShareSheet(items: ["\(track.artistName) — \(track.title)"])
                    .presentationDetents([.medium])
            }
        }
    }

    private var likeButton: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                likeBounce = true
                onLike()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { likeBounce = false }
        } label: {
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .font(.system(size: 22, weight: .regular))
                .foregroundStyle(isLiked ? .red : CrateColor.secondaryText)
                .scaleEffect(likeBounce ? 1.35 : 1.0)
                .frame(width: 36, height: 36)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isLiked)
    }

    private func actionIcon(_ name: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: name)
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(CrateColor.secondaryText)
                .frame(width: 36, height: 36)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct AirPlayIcon: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let v = AVRoutePickerView()
        v.tintColor = UIColor(white: 0.62, alpha: 1)
        v.activeTintColor = .white
        return v
    }
    func updateUIView(_ v: AVRoutePickerView, context: Context) {}
}

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
