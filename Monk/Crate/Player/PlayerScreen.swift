import SwiftUI

struct PlayerScreen: View {
    @EnvironmentObject private var player: PlayerManager
    @EnvironmentObject private var library: LibraryManager
    @State private var showLyrics = false

    var body: some View {
        ZStack {
            CrateColor.background.ignoresSafeArea()
            if let track = player.currentTrack {
                playing(track)
            } else {
                emptyState
            }
        }
        .sheet(isPresented: $showLyrics) {
            if let track = player.currentTrack {
                LyricsCommentsScreen(track: track)
            }
        }
    }

    private func playing(_ track: Track) -> some View {
        let progress = Binding(
            get: { player.audio.currentTime },
            set: { player.audio.seek(to: $0) }
        )
        let volume = Binding(
            get: { Double(player.audio.volume) },
            set: { player.audio.volume = Float($0) }
        )
        let isPlaying = player.audio.state == .playing

        return VStack(spacing: 0) {
            Capsule().fill(CrateColor.surfaceElevated)
                .frame(width: 36, height: 5).padding(.top, 8)
            Spacer(minLength: 12)
            CoverArtView(url: track.artworkURL).padding(.horizontal, 36)
            VStack(spacing: 6) {
                Text(track.title).font(.title2.bold()).foregroundStyle(.white)
                Text(track.artistName).font(.subheadline).foregroundStyle(CrateColor.secondaryText)
            }
            .multilineTextAlignment(.center).padding(.top, 28).padding(.horizontal, 24)

            HStack(spacing: 40) {
                CircleGlassButton(systemName: "backward.fill", size: 64) { player.previous() }
                CircleGlassButton(systemName: isPlaying ? "pause.fill" : "play.fill", size: 84, iconScale: 0.36) { player.toggle() }
                CircleGlassButton(systemName: "forward.fill", size: 64) { player.next() }
            }
            .padding(.top, 28)

            // Bottom glass block
            VStack(spacing: 20) {
                progressSection(progress)
                VolumeRow(value: volume)
                PlayerActionsBar(
                    isLiked: library.isLiked(track),
                    onLike: { library.toggleLike(track) },
                    onComments: { showLyrics = true }
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .padding(.horizontal, 16)
            .padding(.top, 28)

            Spacer(minLength: 16)
        }
    }

    private func progressSection(_ progress: Binding<Double>) -> some View {
        let duration = max(player.audio.duration, 1)
        return VStack(spacing: 8) {
            HStack {
                Text(TimeFormatHelper.format(milliseconds: Int(progress.wrappedValue * 1000)))
                Spacer()
                Text("-" + TimeFormatHelper.format(milliseconds: Int(max(0, duration - progress.wrappedValue) * 1000)))
            }
            .font(.caption).foregroundStyle(CrateColor.secondaryText)
            SliderTrack(value: progress, total: duration)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "music.note").font(.system(size: 40)).foregroundStyle(CrateColor.secondaryText)
            Text(bi("Ничего не играет", "Nothing playing")).font(.headline).foregroundStyle(CrateColor.secondaryText)
        }
    }
}

private struct VolumeRow: View {
    @Binding var value: Double
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "speaker.fill")
            SliderTrack(value: $value, total: 1)
            Image(systemName: "speaker.wave.3.fill")
        }
        .font(.footnote).foregroundStyle(CrateColor.secondaryText)
    }
}
