import SwiftUI
import AVKit

struct PlayerActionsBar: View {
    let isLiked: Bool
    let onLike: () -> Void
    let onComments: () -> Void

    @EnvironmentObject private var player: PlayerManager
    @State private var showShare = false
    @State private var showEqualizer = false
    @State private var likeBounce = false

    var body: some View {
        HStack {
            likeButton
            Spacer()
            glassIcon("bubble.left", action: onComments)
            Spacer()
            glassIcon("slider.vertical.3") { showEqualizer = true }
            Spacer()
            airPlayButton
            Spacer()
            glassIcon("square.and.arrow.up") { showShare = true }
        }
        .sheet(isPresented: $showShare) {
            if let track = player.currentTrack {
                ShareSheet(items: ["\(track.artistName) — \(track.title)"])
                    .presentationDetents([.medium])
            }
        }
        .sheet(isPresented: $showEqualizer) { EqualizerView() }
    }

    // Like button — bounce animation + red tint when liked
    private var likeButton: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                likeBounce = true
                onLike()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { likeBounce = false }
        } label: {
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(isLiked ? .red : .white)
                .scaleEffect(likeBounce ? 1.35 : 1.0)
                .frame(width: 44, height: 44)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .crateGlassInteractive(Circle())
        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isLiked)
    }

    // AirPlay — wrapped in glass circle
    private var airPlayButton: some View {
        AirPlayIcon()
            .frame(width: 44, height: 44)
            .crateGlass(Circle())
    }

    // Generic glass icon button
    private func glassIcon(_ name: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: name)
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .crateGlassInteractive(Circle())
    }
}

private struct AirPlayIcon: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let v = AVRoutePickerView()
        v.tintColor = .white
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
