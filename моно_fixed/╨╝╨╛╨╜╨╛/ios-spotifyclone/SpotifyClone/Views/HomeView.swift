//
//  HomeView.swift
//  SpotifyClone
//
//  Landing screen: time-of-day greeting, quick tiles, recently played,
//  recommended playlists and new releases.
//

import SwiftUI

struct HomeView: View {
    private let store = LibraryStore.shared
    private let player = AudioPlayer.shared
    @State private var showSettings = false

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<18: return "Good afternoon"
        default: return "Good evening"
        }
    }

    private var quickItems: [Playlist] {
        Array(DemoData.playlists.prefix(6))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    quickGrid

                    if !store.recentTracks.isEmpty {
                        recentSection
                    }

                    playlistSection(title: "Made for you", playlists: DemoData.playlists)
                    albumSection(title: "New releases", albums: DemoData.albums)
                    trackSection(title: "Popular tracks", tracks: DemoData.popularTracks)
                    artistSection(title: "Popular artists", artists: DemoData.artists)

                    Color.clear.frame(height: 140)
                }
                .padding(.top, 8)
            }
            .background(Theme.screenGradient(top: Theme.accent.opacity(0.5)).ignoresSafeArea())
            .navigationTitle(greeting)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(Theme.textPrimary)
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showSettings) { SettingsView() }
            .navigationDestination(for: Album.self) { AlbumDetailView(album: $0) }
            .navigationDestination(for: Playlist.self) { PlaylistDetailView(playlist: $0) }
            .navigationDestination(for: Artist.self) { ArtistDetailView(artist: $0) }
        }
    }

    // MARK: - Sections

    private var quickGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
            ForEach(quickItems) { pl in
                NavigationLink(value: pl) {
                    QuickTile(title: pl.title, coverURL: pl.coverURL, seed: pl.id)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Recently played")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(store.recentTracks) { track in
                        Button {
                            playTrack(track, in: store.recentTracks)
                        } label: {
                            MediaCard(title: track.title, subtitle: track.artistName,
                                      coverURL: track.coverURL, seed: track.id, width: 140)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func playlistSection(title: String, playlists: [Playlist]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: title)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(playlists) { pl in
                        NavigationLink(value: pl) {
                            MediaCard(title: pl.title, subtitle: pl.subtitle,
                                      coverURL: pl.coverURL, seed: pl.id)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func albumSection(title: String, albums: [Album]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: title)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(albums) { album in
                        NavigationLink(value: album) {
                            MediaCard(title: album.title, subtitle: album.artistName,
                                      coverURL: album.coverURL, seed: album.id)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func trackSection(title: String, tracks: [Track]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: title)
            VStack(spacing: 0) {
                ForEach(tracks) { track in
                    TrackRow(track: track) { playTrack(track, in: tracks) }
                        .padding(.horizontal, 16)
                }
            }
        }
    }

    private func artistSection(title: String, artists: [Artist]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: title)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(artists) { artist in
                        NavigationLink(value: artist) {
                            MediaCard(title: artist.name, subtitle: "Artist",
                                      coverURL: artist.imageURL, seed: artist.id, circular: true)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func playTrack(_ track: Track, in tracks: [Track]) {
        store.markPlayed(track)
        player.play(track, in: tracks)
    }
}
