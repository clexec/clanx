import Foundation

protocol MusicAPIServiceProtocol {
    func search(term: String, limit: Int) async throws -> [Track]
}

struct ITunesAPIService: MusicAPIServiceProtocol {
    func search(term: String, limit: Int = 25) async throws -> [Track] {
        var components = URLComponents(string: "https://itunes.apple.com/search")
        components?.queryItems = [
            URLQueryItem(name: "term", value: term),
            URLQueryItem(name: "media", value: "music"),
            URLQueryItem(name: "entity", value: "song"),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        guard let url = components?.url else { return [] }
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(ITunesSearchResponse.self, from: data)
        return response.results.compactMap { $0.toTrack() }
    }
}

struct YandexMusicAPIService {
    func search(term: String) async -> [Track] { [] }
}

struct LastFMAPIService {
    func similarArtists(for artist: String) async -> [Artist] { [] }
}
