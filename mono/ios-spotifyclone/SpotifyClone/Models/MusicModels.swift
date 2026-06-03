//
//  MusicModels.swift
//  SpotifyClone
//
//  Core domain models for tracks, albums, artists and playlists.
//  These are normalized shapes used by the UI regardless of the
//  underlying source (Yandex Music API or bundled demo data).
//

import Foundation

/// A single playable track.
struct Track: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let artistName: String
    let albumName: String
    /// Remote cover art URL, when available.
    let coverURL: String?
    /// Direct audio stream/preview URL, when available.
    let audioURL: String?
    /// Duration in seconds.
    let durationSeconds: Int

    var durationText: String {
        let minutes = durationSeconds / 60
        let seconds = durationSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

/// An album grouping a set of tracks.
struct Album: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let artistName: String
    let coverURL: String?
    let year: Int?
    let tracks: [Track]
}

/// A recording artist.
struct Artist: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let imageURL: String?
    let genres: [String]
    let topTracks: [Track]
}

/// A curated or user playlist.
struct Playlist: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let subtitle: String
    let coverURL: String?
    let tracks: [Track]
}

/// A music genre / mood category for the search screen.
struct Genre: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    /// Hex-ish seed for the gradient tile color.
    let colorSeed: String
}
