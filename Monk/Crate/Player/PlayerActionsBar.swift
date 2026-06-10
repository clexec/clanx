import SwiftUI
import AVKit

struct PlayerActionsBar: View {
    let isLiked: Bool
    let onLike: () -> Void
    let onComments: () -> Void

    @EnvironmentObject private var player: PlayerManager
    @State private var showShare = false

    private var shareText: String {
        guard let t = player.currentTrack else { return "" }
        return "\(t.artistName) — \(t.title)"
    }

    var body: some View {
        HStack {
            icon(isLiked ? "heart.fill" : "heart", tint: isLiked ? .red : nil, action: onLike)
            Spacer()
            icon("bubble.left", action: onComments)
            Spacer()
            AirPlayIcon()
                .frame(width: 36, height: 36)
            Spacer()
            icon("forward.end.fill") {
                player.audio.seek(to: max(0, player.audio.duration - 0.5))
            }
            Spacer()
            icon("square.and.arrow.up") { showShare = true }
        }
        .foregroundStyle(CrateColor.secondaryText)
        .sheet(isPresented: $showShare) {
            ShareSheet(items: [shareText])
                .presentationDetents([.medium])
        }
    }

    private func icon(_ name: String, tint: Color? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: name)
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(tint ?? CrateColor.secondaryText)
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
