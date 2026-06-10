import Foundation

// Jamendo — free CC music, full songs streaming
// Docs: https://developer.jamendo.com/v3.0
// Free client_id: b6747d04 (Jamendo demo key — replace with your own at developer.jamendo.com)

private let jamendoClientId = "b6747d04"

struct JamendoAPIService: MusicAPIServiceProtocol {

    func search(term: String, limit: Int = 25) async throws -> [Track] {
        var components = URLComponents(string: "https://api.jamendo.com/v3.0/tracks/")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: jamendoClientId),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "search", value: term),
            URLQueryItem(name: "imagesize", value: "500"),
            URLQueryItem(name: "audioformat", value: "mp31"),
            URLQueryItem(name: "include", value: "musicinfo")
        ]
        guard let url = components.url else { return [] }
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(JamendoResponse.self, from: data)
        return response.results.compactMap { $0.toTrack() }
    }
}

// MARK: - Decodable models

private struct JamendoResponse: Decodable {
    let results: [JamendoTrack]
}

private struct JamendoTrack: Decodable {
    let id: String
    let name: String
    let duration: Int
    let artist_name: String
    let album_name: String
    let image: String?
    let audio: String?           // full streaming URL (mp3)

    func toTrack() -> Track? {
        guard let audioStr = audio, let audioURL = URL(string: audioStr) else { return nil }
        let artwork = image.flatMap { URL(string: $0) }
        let idInt = abs(id.hashValue) & 0x7FFFFFFF
        return Track(
            id: idInt,
            title: name,
            artistName: artist_name,
            albumTitle: album_name,
            artworkURL: artwork,
            previewURL: audioURL,   // Jamendo audio = full song, stored in previewURL
            durationMillis: duration * 1000,
            genre: "Music",
            releaseDate: nil
        )
    }
}
