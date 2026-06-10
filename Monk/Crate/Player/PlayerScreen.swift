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
        let isPlaying = player.audio.state == .playing
        let isLoading = player.audio.state == .loading

        return ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Capsule().fill(CrateColor.surfaceElevated)
                    .frame(width: 36, height: 5).padding(.top, 8)

                CoverArtView(url: track.artworkURL)
                    .padding(.horizontal, 32)
                    .padding(.top, 20)

                VStack(spacing: 6) {
                    Text(track.title)
                        .font(.title2.bold()).foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    Text(track.artistName)
                        .font(.subheadline).foregroundStyle(CrateColor.secondaryText)
                }
                .padding(.top, 24).padding(.horizontal, 24)

                HStack(spacing: 36) {
                    CircleGlassButton(systemName: "backward.fill", size: 62) {
                        player.previous()
                    }
                    ZStack {
                        CircleGlassButton(
                            systemName: isPlaying ? "pause.fill" : "play.fill",
                            size: 80, iconScale: 0.35
                        ) { player.toggle() }
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(1.2)
                                .allowsHitTesting(false)
                        }
                    }
                    CircleGlassButton(systemName: "forward.fill", size: 62) {
                        player.next()
                    }
                }
                .padding(.top, 32)
                .zIndex(10)

                // Bottom glass block
                VStack(spacing: 20) {
                    progressBlock
                    volumeBlock
                    PlayerActionsBar(
                        isLiked: library.isLiked(track),
                        onLike: { library.toggleLike(track) },
                        onComments: { showLyrics = true }
                    )
                    .allowsHitTesting(true)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 22)
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                }
                .padding(.horizontal, 16)
                .padding(.top, 28)
                .zIndex(1)

                Spacer(minLength: 24)
            }
        }
    }

    private var progressBlock: some View {
        let progress = Binding(
            get: { player.audio.currentTime },
            set: { player.audio.seek(to: $0) }
        )
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

    private var volumeBlock: some View {
        let volume = Binding(
            get: { Double(player.audio.volume) },
            set: { player.audio.volume = Float($0) }
        )
        return HStack(spacing: 12) {
            Image(systemName: "speaker.fill")
            SliderTrack(value: volume, total: 1)
            Image(systemName: "speaker.wave.3.fill")
        }
        .font(.footnote).foregroundStyle(CrateColor.secondaryText)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "music.note").font(.system(size: 40)).foregroundStyle(CrateColor.secondaryText)
            Text(bi("Ничего не играет", "Nothing playing")).font(.headline).foregroundStyle(CrateColor.secondaryText)
        }
    }
}
