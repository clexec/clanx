import Foundation
// YouTubeKit inlined

struct YouTubeSearchAPIService: MusicAPIServiceProtocol {
    private let model = YouTubeModel()

    func search(term: String, limit: Int = 25) async throws -> [Track] {
        guard let response = try? await SearchResponse.sendThrowingRequest(
            youtubeModel: model,
            data: [.query: "\(term) music"]
        ) else { return [] }

        var tracks: [Track] = []
        for result in response.results {
            guard tracks.count < limit else { break }
            guard let video = result as? YTVideo else { continue }
            guard let title = video.title, !video.videoId.isEmpty else { continue }

            let artist = video.channel?.name ?? "YouTube"
            let id = video.videoId.hashValue & 0x7FFFFFFF
            let artwork = video.thumbnails.max { ($0.height ?? 0) < ($1.height ?? 0) }?.url
                       ?? video.thumbnails.first?.url
            let duration = (video.timeLengthSeconds ?? 210) * 1000

            tracks.append(Track(
                id: id,
                title: title,
                artistName: artist,
                albumTitle: "YouTube",
                artworkURL: artwork,
                previewURL: nil,
                durationMillis: duration,
                genre: "Music",
                releaseDate: nil
            ))
        }
        return tracks
    }
}
