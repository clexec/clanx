//
//  DetailViews.swift
//  SpotifyClone
//
//  Album, playlist and artist detail screens. Each shows a hero header,
//  a play/save action row and a track list. Yandex-backed items lazily
//  load their tracks on appear.
//

import SwiftUI

/// Shared hero header used by detail screens.
private struct DetailHeader: View {
    let title: String
    let subtitle: String
    let coverURL: String?
    let seed: String
    let circular: Bool

    var body: some View {
        VStack(spacing: 16) {
            Artwork(url: coverURL, seed: seed, cornerRadius: circular ? 0 : 8, circular: circular)
                .frame(width: 200, height: 200)
                .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
    }
}

/// Play + save action row.
private struct DetailActions: View {
    let isSaved: Bool
    let onSave: () -> Void
    let onPlay: () -> Void

    var body: some View {
        HStack {
            Button(action: onSave) {
                Image(systemName: isSaved ? "checkmark.circle.fill" : "plus.circle")
                    .font(.system(size: 30))
                    .foregroundStyle(isSaved ? Theme.accent : Theme.textSecondary)
            }
            .buttonStyle(.plain)

            Spacer()

            GlassIconButton(systemName: "shuffle", size: 44, iconSize: 18) {}

            Button(action: onPlay) {
                ZStack {
                    Circle().fill(Theme.accent).frame(width: 56, height: 56)
                    Image(systemName: "play.fill").font(.system(size: 24)).foregroundStyle(.black)
                }
            }
            .buttonStyle(.plain)
            .padding(.leading, 12)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Album

struct AlbumDetailView: View {
    let album: Album
    private let store = LibraryStore.shared
    private let player = AudioPlayer.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                DetailHeader(title: album.title, subtitle: "Album · \(album.artistName)",
                             coverURL: album.coverURL, seed: album.id, circular: false)
                DetailActions(
                    isSaved: store.isSaved(album: album),
                    onSave: { store.toggleSave(album: album) },
                    onPlay: { if let first = album.tracks.first { play(first) } }
                )
                ForEach(Array(album.tracks.enumerated()), id: \.element.id) { idx, track in
                    TrackRow(track: track, index: idx + 1, showArtwork: false) { play(track) }
                        .padding(.horizontal, 16)
                }
                if album.tracks.isEmpty { emptyTracks }
                Color.clear.frame(height: 160)
            }
        }
        .background(Theme.screenGradient(top: Color.seeded(album.id)).ignoresSafeArea())
        .navigationTitle(album.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func play(_ track: Track) {
        store.markPlayed(track)
        player.play(track, in: album.tracks)
    }

    private var emptyTracks: some View {
        Text("Track list unavailable for this item.")
            .font(.system(size: 14))
            .foregroundStyle(Theme.textSecondary)
            .padding(.top, 24)
    }
}

// MARK: - Playlist

struct PlaylistDetailView: View {
    let playlist: Playlist
    private let store = LibraryStore.shared
    private let player = AudioPlayer.shared

    private var tracks: [Track] {
        playlist.tracks.isEmpty ? DemoData.popularTracks : playlist.tracks
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                DetailHeader(title: playlist.title, subtitle: playlist.subtitle,
                             coverURL: playlist.coverURL, seed: playlist.id, circular: false)
                DetailActions(
                    isSaved: store.isSaved(playlist: playlist),
                    onSave: { store.toggleSave(playlist: playlist) },
                    onPlay: { if let first = tracks.first { play(first) } }
                )
                ForEach(tracks) { track in
                    TrackRow(track: track) { play(track) }
                        .padding(.horizontal, 16)
                }
                Color.clear.frame(height: 160)
            }
        }
        .background(Theme.screenGradient(top: Color.seeded(playlist.id)).ignoresSafeArea())
        .navigationTitle(playlist.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func play(_ track: Track) {
        store.markPlayed(track)
        player.play(track, in: tracks)
    }
}

// MARK: - Artist

struct ArtistDetailView: View {
    let artist: Artist
    private let store = LibraryStore.shared
    private let player = AudioPlayer.shared

    private var tracks: [Track] {
        artist.topTracks.isEmpty ? DemoData.popularTracks.filter { $0.artistName == artist.name } : artist.topTracks
    }

    private var displayTracks: [Track] {
        tracks.isEmpty ? Array(DemoData.popularTracks.prefix(5)) : tracks
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                DetailHeader(title: artist.name,
                             subtitle: artist.genres.isEmpty ? "Artist" : artist.genres.joined(separator: " · "),
                             coverURL: artist.imageURL, seed: artist.id, circular: true)

                HStack {
                    Button {
                        store.toggleFollow(artist: artist)
                    } label: {
                        Text(store.isFollowing(artist: artist) ? "Following" : "Follow")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .overlay(Capsule().strokeBorder(Theme.textSecondary, lineWidth: 1))
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Button {
                        if let first = displayTracks.first { play(first) }
                    } label: {
                        ZStack {
                            Circle().fill(Theme.accent).frame(width: 56, height: 56)
                            Image(systemName: "play.fill").font(.system(size: 24)).foregroundStyle(.black)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                SectionHeader(title: "Popular")
                    .frame(maxWidth: .infinity, alignment: .leading)

                ForEach(Array(displayTracks.enumerated()), id: \.element.id) { idx, track in
                    TrackRow(track: track, index: idx + 1, showArtwork: true) { play(track) }
                        .padding(.horizontal, 16)
                }
                Color.clear.frame(height: 160)
            }
        }
        .background(Theme.screenGradient(top: Color.seeded(artist.id)).ignoresSafeArea())
        .navigationTitle(artist.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func play(_ track: Track) {
        store.markPlayed(track)
        player.play(track, in: displayTracks)
    }
}
