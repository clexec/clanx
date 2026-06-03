//
//  LibraryStore.swift
//  SpotifyClone
//
//  Persisted user state: Yandex token, liked tracks, saved albums/playlists/artists
//  and recently played history. Backed by UserDefaults via Codable.
//

import Foundation
import SwiftUI

/// Source mode the catalog should use.
enum CatalogSource: String {
    case demo
    case yandex
}

/// App-wide observable store for library, settings and history.
@Observable
final class LibraryStore {
    static let shared = LibraryStore()

    private let defaults = UserDefaults.standard
    private enum Keys {
        static let token = "ym_token"
        static let likedTracks = "liked_tracks"
        static let savedAlbums = "saved_albums"
        static let savedPlaylists = "saved_playlists"
        static let savedArtists = "saved_artists"
        static let recent = "recent_tracks"
        static let userTracks = "user_tracks"
    }

    var token: String {
        didSet { defaults.set(token, forKey: Keys.token) }
    }

    var likedTracks: [Track] = [] { didSet { persist(likedTracks, Keys.likedTracks) } }
    var savedAlbums: [Album] = [] { didSet { persist(savedAlbums, Keys.savedAlbums) } }
    var savedPlaylists: [Playlist] = [] { didSet { persist(savedPlaylists, Keys.savedPlaylists) } }
    var savedArtists: [Artist] = [] { didSet { persist(savedArtists, Keys.savedArtists) } }
    var recentTracks: [Track] = [] { didSet { persist(recentTracks, Keys.recent) } }
    var userTracks: [Track] = [] { didSet { persist(userTracks, Keys.userTracks) } }

    var source: CatalogSource { token.isEmpty ? .demo : .yandex }

    private init() {
        token = defaults.string(forKey: Keys.token) ?? ""
        likedTracks = Self.load(Keys.likedTracks)
        savedAlbums = Self.load(Keys.savedAlbums)
        savedPlaylists = Self.load(Keys.savedPlaylists)
        savedArtists = Self.load(Keys.savedArtists)
        recentTracks = Self.load(Keys.recent)
        userTracks = Self.load(Keys.userTracks)

        // Seed the library with a couple of demo items on first launch.
        if savedPlaylists.isEmpty && savedAlbums.isEmpty {
            savedPlaylists = Array(DemoData.playlists.prefix(2))
            savedAlbums = Array(DemoData.albums.prefix(2))
            savedArtists = Array(DemoData.artists.prefix(2))
        }
    }

    // MARK: - Liked tracks

    func isLiked(_ track: Track) -> Bool {
        likedTracks.contains { $0.id == track.id }
    }

    func toggleLike(_ track: Track) {
        if let idx = likedTracks.firstIndex(where: { $0.id == track.id }) {
            likedTracks.remove(at: idx)
        } else {
            likedTracks.insert(track, at: 0)
        }
    }

    // MARK: - Saved collections

    func isSaved(album: Album) -> Bool { savedAlbums.contains { $0.id == album.id } }
    func toggleSave(album: Album) {
        if let idx = savedAlbums.firstIndex(where: { $0.id == album.id }) { savedAlbums.remove(at: idx) }
        else { savedAlbums.insert(album, at: 0) }
    }

    func isSaved(playlist: Playlist) -> Bool { savedPlaylists.contains { $0.id == playlist.id } }
    func toggleSave(playlist: Playlist) {
        if let idx = savedPlaylists.firstIndex(where: { $0.id == playlist.id }) { savedPlaylists.remove(at: idx) }
        else { savedPlaylists.insert(playlist, at: 0) }
    }

    func isFollowing(artist: Artist) -> Bool { savedArtists.contains { $0.id == artist.id } }
    func toggleFollow(artist: Artist) {
        if let idx = savedArtists.firstIndex(where: { $0.id == artist.id }) { savedArtists.remove(at: idx) }
        else { savedArtists.insert(artist, at: 0) }
    }

    // MARK: - User tracks

    func addUserTrack(_ track: Track) {
        userTracks.insert(track, at: 0)
    }

    func removeUserTrack(_ track: Track) {
        userTracks.removeAll { $0.id == track.id }
    }

    // MARK: - History

    func markPlayed(_ track: Track) {
        recentTracks.removeAll { $0.id == track.id }
        recentTracks.insert(track, at: 0)
        if recentTracks.count > 20 { recentTracks = Array(recentTracks.prefix(20)) }
    }

    // MARK: - Persistence helpers

    private func persist<T: Encodable>(_ value: T, _ key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private static func load<T: Decodable>(_ key: String) -> [T] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([T].self, from: data) else { return [] }
        return decoded
    }
}
