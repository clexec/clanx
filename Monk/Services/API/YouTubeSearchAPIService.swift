import Foundation
// YouTubeKit inlined

struct YouTubeSearchAPIService: MusicAPIServiceProtocol {
    private let model = YouTubeModel()

    func search(term: String, limit: Int = 25) async throws -> [Track] {
        guard let response = try? await SearchResponse.sendThrowingRequest(
            youtubeModel: model,
            data: [.query: "\(term) music"]
        ) else { return [] }

        return response.results
            .compactMap { $0 as? YTVideo }
            .prefix(limit)
            .compactMap { video -> Track? in
                guard !video.videoId.isEmpty, let title = video.title else { return nil }
                let artist = video.channel?.name ?? "YouTube"
                let id = video.videoId.hashValue & 0x7FFFFFFF
                let artwork = video.thumbnails.max(by: { ($0.size?.height ?? 0) < ($1.size?.height ?? 0) })?.url
                                ?? video.thumbnails.first?.url
                let duration = (video.timeLengthSeconds ?? 210) * 1000
                return Track(
                    id: id,
                    title: title,
                    artistName: artist,
                    albumTitle: "YouTube",
                    artworkURL: artwork,
                    previewURL: nil,
                    durationMillis: duration,
                    genre: "Music",
                    releaseDate: nil
                )
            }
    }
}
