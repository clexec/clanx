//
//  MiniPlayerView.swift
//  SpotifyClone
//
//  Compact now-playing bar shown above the tab bar on a glass surface.
//

import SwiftUI

struct MiniPlayerView: View {
    let onExpand: () -> Void
    private let player = AudioPlayer.shared
    private let store = LibraryStore.shared

    var body: some View {
        if let track = player.currentTrack {
            Button(action: onExpand) {
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        Artwork(url: track.coverURL, seed: track.id, cornerRadius: 6)
                            .frame(width: 44, height: 44)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(track.title)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Theme.textPrimary)
                                .lineLimit(1)
                            Text(track.artistName)
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.textSecondary)
                                .lineLimit(1)
                        }

                        Spacer(minLength: 4)

                        Image(systemName: store.isLiked(track) ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .foregroundStyle(store.isLiked(track) ? Theme.accent : Theme.textPrimary)
                            .onTapGesture { store.toggleLike(track) }

                        Button {
                            player.togglePlayPause()
                        } label: {
                            Image(systemName: player.isLoading ? "circle.dotted" : (player.isPlaying ? "pause.fill" : "play.fill"))
                                .font(.system(size: 20))
                                .foregroundStyle(Theme.textPrimary)
                                .symbolEffect(.rotate, isActive: player.isLoading)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)

                    // Thin progress line
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.15))
                            Capsule().fill(Theme.accent)
                                .frame(width: max(0, geo.size.width * player.progress))
                        }
                    }
                    .frame(height: 2)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 6)
                }
                // ✅ ИСПРАВЛЕНО: используем гибридный модификатор БЕЗ clipShape после него
                .hybridLiquidGlass(cornerRadius: 14, tint: Color.seeded(track.id))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [.white.opacity(0.25), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }
}
