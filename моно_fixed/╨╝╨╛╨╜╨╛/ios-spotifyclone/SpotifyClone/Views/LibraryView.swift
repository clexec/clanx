//
//  LibraryView.swift
//  SpotifyClone
//
//  "Your Library" screen with filter chips for Playlists / Artists /
//  Albums / Liked songs, plus a list of saved items.
//

import SwiftUI

private enum LibraryFilter: String, CaseIterable, Identifiable {
    case playlists = "Playlists"
    case artists = "Artists"
    case albums = "Albums"
    case liked = "Liked Songs"
    var id: String { rawValue }
}

struct LibraryView: View {
    @State private var filter: LibraryFilter = .playlists
    private let store = LibraryStore.shared
    private let player = AudioPlayer.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    filterChips

                    switch filter {
                    case .playlists: playlistList
                    case .artists: artistList
                    case .albums: albumList
                    case .liked: likedList
                    }

                    Color.clear.frame(height: 140)
                }
                .padding(.top, 8)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Your Library")
            .navigationDestination(for: Album.self) { AlbumDetailView(album: $0) }
            .navigationDestination(for: Playlist.self) { PlaylistDetailView(playlist: $0) }
            .navigationDestination(for: Artist.self) { ArtistDetailView(artist: $0) }
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(LibraryFilter.allCases) { item in
                    let isSelected = filter == item
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { filter = item }
                    } label: {
                        Text(item.rawValue)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(isSelected ? Theme.background : Theme.textPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(isSelected ? Theme.accent : Color.white.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var playlistList: some View {
        Group {
            if store.savedPlaylists.isEmpty {
                emptyState("Save playlists to see them here")
            } else {
                VStack(spacing: 4) {
                    ForEach(store.savedPlaylists) { pl in
                        NavigationLink(value: pl) {
                            libraryRow(title: pl.title, subtitle: "Playlist · \(pl.subtitle)",
                                       coverURL: pl.coverURL, seed: pl.id, circular: false)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private var artistList: some View {
        Group {
            if store.savedArtists.isEmpty {
                emptyState("Follow artists to see them here")
            } else {
                VStack(spacing: 4) {
                    ForEach(store.savedArtists) { artist in
                        NavigationLink(value: artist) {
                            libraryRow(title: artist.name, subtitle: "Artist",
                                       coverURL: artist.imageURL, seed: artist.id, circular: true)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private var albumList: some View {
        Group {
            if store.savedAlbums.isEmpty {
                emptyState("Save albums to see them here")
            } else {
                VStack(spacing: 4) {
                    ForEach(store.savedAlbums) { album in
                        NavigationLink(value: album) {
                            libraryRow(title: album.title, subtitle: "Album · \(album.artistName)",
                                       coverURL: album.coverURL, seed: album.id, circular: false)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private var likedList: some View {
        Group {
            if store.likedTracks.isEmpty {
                emptyState("Songs you like will appear here")
            } else {
                VStack(spacing: 0) {
                    ForEach(store.likedTracks) { track in
                        TrackRow(track: track) {
                            store.markPlayed(track)
                            player.play(track, in: store.likedTracks)
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
        }
    }

    private func libraryRow(title: String, subtitle: String, coverURL: String?, seed: String, circular: Bool) -> some View {
        HStack(spacing: 12) {
            Artwork(url: coverURL, seed: seed, cornerRadius: 6, circular: circular)
                .frame(width: 56, height: 56)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.textTertiary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }

    private func emptyState(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "music.note.list")
                .font(.system(size: 40))
                .foregroundStyle(Theme.textTertiary)
            Text(message)
                .font(.system(size: 15))
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}
