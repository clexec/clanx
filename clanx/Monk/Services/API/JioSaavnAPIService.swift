import Foundation

struct JioSaavnAPIService: MusicAPIServiceProtocol {
    private let base = "https://saavn.dev/api"

    func search(term: String, limit: Int = 20) async throws -> [Track] {
        var comps = URLComponents(string: "\(base)/search/songs")!
        comps.queryItems = [
            URLQueryItem(name: "query", value: term),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        guard let url = comps.url else { return [] }
        let (data, _) = try await URLSession.shared.data(from: url)
        let resp = try JSONDecoder().decode(SaavnSearchResponse.self, from: data)
        return resp.data?.results?.compactMap { $0.toTrack() } ?? []
    }
}

// MARK: - DTOs

private struct SaavnSearchResponse: Decodable {
    let data: SaavnSearchData?
}

private struct SaavnSearchData: Decodable {
    let results: [SaavnSongDTO]?
}

private struct SaavnSongDTO: Decodable {
    let id: String
    let name: String?
    let duration: Int?
    let artists: SaavnArtistsWrap?
    let album: SaavnAlbum?
    let image: [SaavnQualityURL]?
    let downloadUrl: [SaavnQualityURL]?

    func toTrack() -> Track? {
        guard let title = name else { return nil }
        let artist = artists?.primary?.first?.name ?? "Unknown"
        let artwork = image?.last.flatMap { URL(string: $0.url) }
        // Prefer 320kbps, fallback to last available
        let audioURL = (downloadUrl?.first(where: { $0.quality == "320kbps" }) ?? downloadUrl?.last)
            .flatMap { URL(string: $0.url) }
        let hashId = id.utf8.reduce(0) { ($0 &* 31) &+ Int($1) }
        return Track(
            id: hashId,
            title: title,
            artistName: artist,
            albumTitle: album?.name ?? "Single",
            artworkURL: artwork,
            previewURL: audioURL,
            durationMillis: (duration ?? 0) * 1_000,
            genre: "Music",
            releaseDate: nil
        )
    }
}

private struct SaavnArtistsWrap: Decodable {
    let primary: [SaavnArtistDTO]?
}

private struct SaavnArtistDTO: Decodable {
    let name: String?
}

private struct SaavnAlbum: Decodable {
    let name: String?
}

private struct SaavnQualityURL: Decodable {
    let quality: String?
    let url: String
}
