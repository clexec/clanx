//
//  YandexMusicService.swift
//  SpotifyClone
//
//  Lightweight client for the (unofficial) Yandex Music API.
//  When a valid OAuth token is configured it fetches real data; otherwise
//  it transparently falls back to the bundled demo catalog so the app is
//  fully usable out of the box.
//
//  API reference (unofficial): https://github.com/p0rterB/YM-API
//

import Foundation
import CryptoKit

/// Errors surfaced by the Yandex Music client.
enum YandexMusicError: LocalizedError {
    case noToken
    case badResponse(Int)
    case decoding
    case noDownloadInfo

    var errorDescription: String? {
        switch self {
        case .noToken: return "No Yandex Music token configured."
        case .badResponse(let code): return "Server returned status \(code)."
        case .decoding: return "Could not read the server response."
        case .noDownloadInfo: return "No streamable source for this track."
        }
    }
}

/// Stateless networking client for Yandex Music.
/// All methods are async and isolated to the main actor by project default;
/// heavy decoding is offloaded via `nonisolated` helpers.
final class YandexMusicService {
    static let shared = YandexMusicService()

    private let baseURL = "https://api.music.yandex.net"
    private let session = URLSession(configuration: .default)

    private init() {}

    private func request(path: String, query: [URLQueryItem] = [], token: String) -> URLRequest? {
        guard var components = URLComponents(string: baseURL + path) else { return nil }
        if !query.isEmpty { components.queryItems = query }
        guard let url = components.url else { return nil }
        var req = URLRequest(url: url)
        req.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("Yandex-Music-API", forHTTPHeaderField: "X-Yandex-Music-Client")
        req.setValue("ru", forHTTPHeaderField: "Accept-Language")
        return req
    }

    private func fetchData(path: String, query: [URLQueryItem] = [], token: String) async throws -> Data {
        guard !token.isEmpty else { throw YandexMusicError.noToken }
        guard let req = request(path: path, query: query, token: token) else { throw YandexMusicError.badResponse(-1) }
        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse else { throw YandexMusicError.badResponse(-1) }
        guard (200..<300).contains(http.statusCode) else { throw YandexMusicError.badResponse(http.statusCode) }
        return data
    }

    // MARK: - Public API

    /// Search across tracks, artists, albums and playlists.
    func search(_ text: String, token: String) async throws -> SearchResults {
        let data = try await fetchData(
            path: "/search",
            query: [
                .init(name: "text", value: text),
                .init(name: "type", value: "all"),
                .init(name: "page", value: "0"),
                .init(name: "nocorrect", value: "false")
            ],
            token: token
        )
        return try Self.parseSearch(data)
    }

    /// Resolve a directly playable URL for a track id, using the download-info flow.
    func streamURL(trackId: String, token: String) async throws -> URL {
        let data = try await fetchData(
            path: "/tracks/\(trackId)/download-info",
            query: [.init(name: "format", value: "json")],
            token: token
        )
        guard let infoURL = Self.bestDownloadInfoURL(data) else { throw YandexMusicError.noDownloadInfo }
        // Fetch the XML download descriptor.
        let (xmlData, _) = try await session.data(from: infoURL)
        guard let url = Self.buildStreamURL(from: xmlData) else { throw YandexMusicError.noDownloadInfo }
        return url
    }

    // MARK: - Cover helpers

    /// Yandex cover URLs contain a `%%` size placeholder which must be replaced.
    static func resolveCover(_ raw: String?, size: Int = 400) -> String? {
        guard let raw, !raw.isEmpty else { return nil }
        let withScheme = raw.hasPrefix("http") ? raw : "https://" + raw
        return withScheme.replacingOccurrences(of: "%%", with: "\(size)x\(size)")
    }

    // MARK: - Parsing (nonisolated: runs off the main actor safely)

    nonisolated static func parseSearch(_ data: Data) throws -> SearchResults {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let result = json["result"] as? [String: Any] else {
            throw YandexMusicError.decoding
        }

        func tracks(from container: [String: Any]?) -> [Track] {
            guard let results = container?["results"] as? [[String: Any]] else { return [] }
            return results.compactMap { parseTrack($0) }
        }

        var trackList = tracks(from: result["tracks"] as? [String: Any])

        var albumList: [Album] = []
        if let albums = (result["albums"] as? [String: Any])?["results"] as? [[String: Any]] {
            albumList = albums.compactMap { parseAlbum($0) }
        }

        var artistList: [Artist] = []
        if let artists = (result["artists"] as? [String: Any])?["results"] as? [[String: Any]] {
            artistList = artists.compactMap { parseArtist($0) }
        }

        var playlistList: [Playlist] = []
        if let playlists = (result["playlists"] as? [String: Any])?["results"] as? [[String: Any]] {
            playlistList = playlists.compactMap { parsePlaylist($0) }
        }

        // Some responses surface "best" only.
        if trackList.isEmpty, let best = result["best"] as? [String: Any],
           best["type"] as? String == "track", let t = best["result"] as? [String: Any],
           let track = parseTrack(t) {
            trackList = [track]
        }

        return SearchResults(tracks: trackList, albums: albumList, artists: artistList, playlists: playlistList)
    }

    nonisolated static func parseTrack(_ dict: [String: Any]) -> Track? {
        guard let idValue = dict["id"] else { return nil }
        let id = "\(idValue)"
        let title = dict["title"] as? String ?? "Unknown"
        let durationMs = dict["durationMs"] as? Int ?? 0
        let artists = dict["artists"] as? [[String: Any]] ?? []
        let artistName = artists.compactMap { $0["name"] as? String }.joined(separator: ", ")
        let albums = dict["albums"] as? [[String: Any]] ?? []
        let albumName = albums.first?["title"] as? String ?? ""
        let cover = (dict["coverUri"] as? String) ?? (albums.first?["coverUri"] as? String)
        return Track(
            id: id,
            title: title,
            artistName: artistName.isEmpty ? "Unknown Artist" : artistName,
            albumName: albumName,
            coverURL: resolveCover(cover),
            audioURL: nil,
            durationSeconds: durationMs / 1000
        )
    }

    nonisolated static func parseAlbum(_ dict: [String: Any]) -> Album? {
        guard let idValue = dict["id"] else { return nil }
        let artists = dict["artists"] as? [[String: Any]] ?? []
        let artistName = artists.compactMap { $0["name"] as? String }.joined(separator: ", ")
        let trackDicts = (dict["volumes"] as? [[[String: Any]]])?.flatMap { $0 } ?? []
        return Album(
            id: "\(idValue)",
            title: dict["title"] as? String ?? "Unknown",
            artistName: artistName.isEmpty ? "Various Artists" : artistName,
            coverURL: resolveCover(dict["coverUri"] as? String),
            year: dict["year"] as? Int,
            tracks: trackDicts.compactMap { parseTrack($0) }
        )
    }

    nonisolated static func parseArtist(_ dict: [String: Any]) -> Artist? {
        guard let idValue = dict["id"] else { return nil }
        var cover: String?
        if let ogImage = dict["ogImage"] as? String { cover = ogImage }
        else if let coverDict = dict["cover"] as? [String: Any] { cover = coverDict["uri"] as? String }
        let genres = dict["genres"] as? [String] ?? []
        return Artist(
            id: "\(idValue)",
            name: dict["name"] as? String ?? "Unknown",
            imageURL: resolveCover(cover),
            genres: genres,
            topTracks: []
        )
    }

    nonisolated static func parsePlaylist(_ dict: [String: Any]) -> Playlist? {
        guard let idValue = dict["kind"] ?? dict["id"] else { return nil }
        var cover: String?
        if let coverDict = dict["cover"] as? [String: Any] { cover = coverDict["uri"] as? String }
        let count = dict["trackCount"] as? Int ?? 0
        let owner = (dict["owner"] as? [String: Any])?["name"] as? String ?? "Yandex Music"
        return Playlist(
            id: "\(idValue)",
            title: dict["title"] as? String ?? "Playlist",
            subtitle: count > 0 ? "\(count) tracks · \(owner)" : owner,
            coverURL: resolveCover(cover),
            tracks: []
        )
    }

    // MARK: - Download-info flow

    nonisolated static func bestDownloadInfoURL(_ data: Data) -> URL? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        let variants = (json["result"] as? [[String: Any]]) ?? (json["downloadInfo"] as? [[String: Any]]) ?? []
        // Prefer the highest bitrate mp3 variant.
        let best = variants
            .filter { ($0["codec"] as? String) == "mp3" }
            .max { (($0["bitrateInKbps"] as? Int) ?? 0) < (($1["bitrateInKbps"] as? Int) ?? 0) }
            ?? variants.first
        guard let urlString = best?["downloadInfoUrl"] as? String else { return nil }
        return URL(string: urlString)
    }

    /// Parse the XML descriptor and compute the signed stream URL.
    nonisolated static func buildStreamURL(from xml: Data) -> URL? {
        guard let text = String(data: xml, encoding: .utf8) else { return nil }
        func value(_ tag: String) -> String? {
            guard let start = text.range(of: "<\(tag)>"),
                  let end = text.range(of: "</\(tag)>") else { return nil }
            return String(text[start.upperBound..<end.lowerBound])
        }
        guard let host = value("host"),
              let path = value("path"),
              let ts = value("ts"),
              let s = value("s") else { return nil }
        // Sign salt per the unofficial protocol.
        let salt = "XGRlBW9FXlekgbPrRHuSiA"
        let signSource = salt + path.dropFirst() + s
        let digest = Insecure.MD5.hash(data: Data(signSource.utf8))
        let sign = digest.map { String(format: "%02x", $0) }.joined()
        let urlString = "https://\(host)/get-mp3/\(sign)/\(ts)\(path)"
        return URL(string: urlString)
    }
}

/// Aggregated search results.
struct SearchResults {
    var tracks: [Track]
    var albums: [Album]
    var artists: [Artist]
    var playlists: [Playlist]

    static let empty = SearchResults(tracks: [], albums: [], artists: [], playlists: [])
    var isEmpty: Bool { tracks.isEmpty && albums.isEmpty && artists.isEmpty && playlists.isEmpty }
}
