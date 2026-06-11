import SwiftUI

struct PlayerScreen: View {
    @EnvironmentObject private var player: PlayerManager
    @EnvironmentObject private var library: LibraryManager
    @State private var showLyrics = false

    var body: some View {
        ZStack {
            // Dark gradient so glass effect is always visible
            ZStack {
                Color.black.ignoresSafeArea()
                LinearGradient(
                    colors: [
                        Color(red: 0.12, green: 0.07, blue: 0.22),
                        Color(red: 0.05, green: 0.07, blue: 0.18),
                        Color.black
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
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

                // Playback controls — GlassEffectContainer merges adjacent glass circles
                GlassEffectContainer(spacing: 16) {
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
                }
                .padding(.top, 32)
                .zIndex(10)

                // Progress bar — free-floating, no glass container
                progressBlock
                    .padding(.horizontal, 24)
                    .padding(.top, 28)

                // Volume
                volumeBlock
                    .padding(.horizontal, 24)

                // Actions bar in its own glass pill
                PlayerActionsBar(
                    isLiked: library.isLiked(track),
                    onLike: { library.toggleLike(track) },
                    onComments: { showLyrics = true }
                )
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .zIndex(1)

                Spacer(minLength: 24)
            }
        }
    }

    private var progressBlock: some View {
        let duration = max(player.audio.duration, 1)
        let progress = Binding(
            get: { player.audio.currentTime },
            set: { player.audio.seek(to: $0) }
        )
        return VStack(spacing: 8) {
            SliderTrack(value: progress, total: duration, height: 4, knob: 18)
            HStack {
                Text(TimeFormatHelper.format(milliseconds: Int(player.audio.currentTime * 1000)))
                Spacer()
                Text("-" + TimeFormatHelper.format(milliseconds: Int(max(0, duration - player.audio.currentTime) * 1000)))
            }
            .font(.caption2).foregroundStyle(CrateColor.secondaryText)
        }
    }

    private var volumeBlock: some View {
        let volume = Binding(
            get: { Double(player.audio.volume) },
            set: { player.audio.volume = Float($0) }
        )
        return HStack(spacing: 10) {
            Image(systemName: "speaker.fill").font(.caption).foregroundStyle(CrateColor.secondaryText)
            SliderTrack(value: volume, total: 1, height: 3, knob: 16)
            Image(systemName: "speaker.wave.3.fill").font(.caption).foregroundStyle(CrateColor.secondaryText)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "music.note").font(.system(size: 40)).foregroundStyle(CrateColor.secondaryText)
            Text(bi("Ничего не играет", "Nothing playing")).font(.headline).foregroundStyle(CrateColor.secondaryText)
        }
    }
}
