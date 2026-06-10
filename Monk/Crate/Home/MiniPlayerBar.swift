import SwiftUI

struct MiniPlayerBar: View {
    @EnvironmentObject private var player: PlayerManager

    var body: some View {
        if let track = player.currentTrack {
            HStack(spacing: 12) {
                CoverArtView(url: track.artworkURL, corner: 8).frame(width: 40, height: 40)
                VStack(alignment: .leading, spacing: 1) {
                    Text(track.title).font(.subheadline.weight(.semibold)).foregroundStyle(.white).lineLimit(1)
                    Text(track.artistName).font(.caption).foregroundStyle(CrateColor.secondaryText).lineLimit(1)
                }
                Spacer()
                Button { player.toggle() } label: {
                    Image(systemName: player.audio.state == .playing ? "pause.fill" : "play.fill")
                        .font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                        .frame(width: 40, height: 40).contentShape(Circle())
                }
                .buttonStyle(.plain)
                .crateGlass(Circle())
            }
            .padding(8).crateGlass(Capsule())
        }
    }
}
