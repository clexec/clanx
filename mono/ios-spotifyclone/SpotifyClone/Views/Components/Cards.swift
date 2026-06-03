//
//  Cards.swift
//  SpotifyClone
//
//  Reusable list rows and grid cards for tracks, albums, playlists, artists.
//

import SwiftUI

/// A horizontal track row used in lists and detail screens.
struct TrackRow: View {
    let track: Track
    var index: Int? = nil
    var showArtwork: Bool = true
    let onTap: () -> Void

    private let store = LibraryStore.shared
    private let player = AudioPlayer.shared

    private var isCurrent: Bool { player.currentTrack?.id == track.id }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                if let index {
                    Text("\(index)")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Theme.textTertiary)
                        .frame(width: 24)
                } else if showArtwork {
                    Artwork(url: track.coverURL, seed: track.id, cornerRadius: 6)
                        .frame(width: 50, height: 50)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(track.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(isCurrent ? Theme.accent : Theme.textPrimary)
                        .lineLimit(1)
                    Text(track.artistName)
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                if isCurrent && player.isPlaying {
                    Image(systemName: "waveform")
                        .symbolEffect(.variableColor.iterative, options: .repeating)
                        .foregroundStyle(Theme.accent)
                        .font(.system(size: 16))
                }

                Image(systemName: store.isLiked(track) ? "heart.fill" : "heart")
                    .font(.system(size: 15))
                    .foregroundStyle(store.isLiked(track) ? Theme.accent : Theme.textTertiary)
                    .onTapGesture {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        store.toggleLike(track)
                    }
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// A square media card for albums and playlists in horizontal carousels.
struct MediaCard: View {
    let title: String
    let subtitle: String
    let coverURL: String?
    let seed: String
    var circular: Bool = false
    var width: CGFloat = 150

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Artwork(url: coverURL, seed: seed, cornerRadius: 8, circular: circular)
                .frame(width: width, height: width)
                .shadow(color: .black.opacity(0.4), radius: 8, y: 4)

            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(1)
                .multilineTextAlignment(.leading)

            Text(subtitle)
                .font(.system(size: 12))
                .foregroundStyle(Theme.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .frame(width: width, alignment: .leading)
    }
}

/// Compact tile used on the Home top grid.
struct QuickTile: View {
    let title: String
    let coverURL: String?
    let seed: String

    var body: some View {
        HStack(spacing: 10) {
            Artwork(url: coverURL, seed: seed, cornerRadius: 4)
                .frame(width: 54, height: 54)
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(2)
            Spacer(minLength: 0)
        }
        .padding(.trailing, 8)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

/// Section header with optional "see all" affordance.
struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 22, weight: .bold))
            .foregroundStyle(Theme.textPrimary)
            .padding(.horizontal, 16)
    }
}
