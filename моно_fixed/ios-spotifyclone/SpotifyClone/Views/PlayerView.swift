//
//  PlayerView.swift
//  SpotifyClone
//
//  Full-screen now-playing experience: large artwork, scrubber,
//  transport controls and shuffle/repeat on an ambient gradient.
//

import SwiftUI

struct PlayerView: View {
    @Environment(\.dismiss) private var dismiss
    private let player = AudioPlayer.shared
    private let store = LibraryStore.shared

    @State private var isScrubbing = false
    @State private var scrubValue: Double = 0

    var body: some View {
        ZStack {
            backgroundGradient

            if let track = player.currentTrack {
                VStack(spacing: 0) {
                    header(track)
                    Spacer(minLength: 0)
                    artwork(track)
                    Spacer(minLength: 0)
                    info(track)
                    scrubber
                    controls
                    bottomBar
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 28)
            } else {
                Text("Nothing playing").foregroundStyle(.white)
            }
        }
    }

    // MARK: - Pieces

    private var backgroundGradient: some View {
        let seed = player.currentTrack?.id ?? "default"
        return LinearGradient(
            colors: [Color.seeded(seed).opacity(0.85), Theme.background, Theme.background],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private func header(_ track: Track) -> some View {
        HStack {
            GlassIconButton(systemName: "chevron.down", size: 40, iconSize: 16) { dismiss() }
            Spacer()
            VStack(spacing: 2) {
                Text("PLAYING FROM")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white.opacity(0.7))
                Text(track.albumName.isEmpty ? "Your music" : track.albumName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }
            Spacer()
            GlassIconButton(systemName: "ellipsis", size: 40, iconSize: 16) {}
        }
    }

    private func artwork(_ track: Track) -> some View {
        Artwork(url: track.coverURL, seed: track.id, cornerRadius: 16)
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .shadow(color: .black.opacity(0.5), radius: 24, y: 12)
            .scaleEffect(player.isPlaying ? 1 : 0.92)
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: player.isPlaying)
            .padding(.vertical, 12)
    }

    private func info(_ track: Track) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(track.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(track.artistName)
                    .font(.system(size: 16))
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(1)
            }
            Spacer()
            Button {
                store.toggleLike(track)
            } label: {
                Image(systemName: store.isLiked(track) ? "heart.fill" : "heart")
                    .font(.system(size: 26))
                    .foregroundStyle(store.isLiked(track) ? Theme.accent : .white)
                    .symbolEffect(.bounce, value: store.isLiked(track))
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 8)
    }

    private var scrubber: some View {
        VStack(spacing: 4) {
            Slider(
                value: Binding(
                    get: { isScrubbing ? scrubValue : player.progress },
                    set: { scrubValue = $0; isScrubbing = true }
                ),
                in: 0...1,
                onEditingChanged: { editing in
                    if !editing {
                        player.seek(to: scrubValue)
                        isScrubbing = false
                    }
                }
            )
            .tint(.white)

            HStack {
                Text(timeText(player.currentTime))
                Spacer()
                Text(timeText(player.duration))
            }
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.white.opacity(0.6))
        }
        .padding(.top, 12)
    }

    private var controls: some View {
        HStack {
            Button {
                player.shuffleEnabled.toggle()
            } label: {
                Image(systemName: "shuffle")
                    .font(.system(size: 20))
                    .foregroundStyle(player.shuffleEnabled ? Theme.accent : .white)
            }
            .buttonStyle(.plain)

            Spacer()

            Button { player.previous() } label: {
                Image(systemName: "backward.fill").font(.system(size: 30)).foregroundStyle(.white)
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                player.togglePlayPause()
            } label: {
                ZStack {
                    Circle().fill(.white).frame(width: 72, height: 72)
                    if player.isLoading {
                        ProgressView().tint(.black)
                    } else {
                        Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.black)
                    }
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Button { player.next() } label: {
                Image(systemName: "forward.fill").font(.system(size: 30)).foregroundStyle(.white)
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                player.repeatEnabled.toggle()
            } label: {
                Image(systemName: "repeat")
                    .font(.system(size: 20))
                    .foregroundStyle(player.repeatEnabled ? Theme.accent : .white)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 20)
    }

    private var bottomBar: some View {
        HStack {
            Image(systemName: "hifispeaker")
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
            Image(systemName: "list.bullet")
                .foregroundStyle(.white.opacity(0.7))
        }
        .font(.system(size: 16))
        .padding(.top, 24)
    }

    private func timeText(_ seconds: Double) -> String {
        guard seconds.isFinite, seconds > 0 else { return "0:00" }
        let total = Int(seconds)
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}
