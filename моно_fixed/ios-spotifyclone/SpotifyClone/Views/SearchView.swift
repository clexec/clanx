//
//  SearchView.swift
//  SpotifyClone
//
//  Search screen: live search across Yandex Music (or local demo catalog),
//  plus a colorful genre browse grid when idle.
//

import SwiftUI

struct SearchView: View {
    @State private var query = ""
    @State private var results: SearchResults = .empty
    @State private var isSearching = false
    @State private var searchTask: Task<Void, Never>?

    private let store = LibraryStore.shared
    private let player = AudioPlayer.shared

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                if query.isEmpty {
                    browseGrid
                } else {
                    resultsList
                }
                Color.clear.frame(height: 140)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Search")
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Songs, artists, albums")
            .onChange(of: query) { _, newValue in scheduleSearch(newValue) }
            .navigationDestination(for: Album.self) { AlbumDetailView(album: $0) }
            .navigationDestination(for: Artist.self) { ArtistDetailView(artist: $0) }
        }
    }

    // MARK: - Browse

    private var browseGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Browse all")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Theme.textPrimary)
                .padding(.horizontal, 16)
                .padding(.top, 8)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(DemoData.genres) { genre in
                    genreTile(genre)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func genreTile(_ genre: Genre) -> some View {
        let color = Color.seeded(genre.colorSeed)
        return ZStack(alignment: .topLeading) {
            LinearGradient(colors: [color, color.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
            Text(genre.name)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .padding(12)
            Artwork(url: nil, seed: genre.id, cornerRadius: 6)
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(25))
                .offset(x: 90, y: 30)
        }
        .frame(height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .onTapGesture { query = genre.name }
    }

    // MARK: - Results

    private var resultsList: some View {
        VStack(alignment: .leading, spacing: 20) {
            if isSearching {
                HStack {
                    ProgressView().tint(Theme.accent)
                    Text("Searching…").foregroundStyle(Theme.textSecondary)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            } else if results.isEmpty {
                emptyState
            } else {
                if !results.tracks.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "Songs")
                        ForEach(results.tracks) { track in
                            TrackRow(track: track) {
                                store.markPlayed(track)
                                player.play(track, in: results.tracks)
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
                if !results.artists.isEmpty {
                    horizontalArtists
                }
                if !results.albums.isEmpty {
                    horizontalAlbums
                }
            }
        }
        .padding(.top, 8)
    }

    private var horizontalArtists: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Artists")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(results.artists) { artist in
                        NavigationLink(value: artist) {
                            MediaCard(title: artist.name, subtitle: "Artist",
                                      coverURL: artist.imageURL, seed: artist.id, circular: true, width: 130)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private var horizontalAlbums: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Albums")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(results.albums) { album in
                        NavigationLink(value: album) {
                            MediaCard(title: album.title, subtitle: album.artistName,
                                      coverURL: album.coverURL, seed: album.id, width: 130)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 44))
                .foregroundStyle(Theme.textTertiary)
            Text("No results for \"\(query)\"")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
            Text("Try a different spelling or keyword.")
                .font(.system(size: 14))
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    // MARK: - Search execution

    private func scheduleSearch(_ text: String) {
        searchTask?.cancel()
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            results = .empty
            isSearching = false
            return
        }
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(350))
            if Task.isCancelled { return }
            await runSearch(trimmed)
        }
    }

    private func runSearch(_ text: String) async {
        isSearching = true
        defer { isSearching = false }

        if store.source == .yandex {
            do {
                let remote = try await YandexMusicService.shared.search(text, token: store.token)
                if !Task.isCancelled { results = remote }
                return
            } catch {
                print("[Search] Yandex search failed, using local: \(error.localizedDescription)")
            }
        }
        // Local demo search fallback.
        let lower = text.lowercased()
        let tracks = DemoData.allTracks.filter {
            $0.title.lowercased().contains(lower) || $0.artistName.lowercased().contains(lower)
        }
        let albums = DemoData.albums.filter {
            $0.title.lowercased().contains(lower) || $0.artistName.lowercased().contains(lower)
        }
        let artists = DemoData.artists.filter { $0.name.lowercased().contains(lower) }
        if !Task.isCancelled {
            results = SearchResults(tracks: tracks, albums: albums, artists: artists, playlists: [])
        }
    }
}
