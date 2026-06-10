import Foundation
import YouTubeKit

struct YouTubeStreamResolver: StreamResolving {
    let source: MusicSource = .youtube
    private let model = YouTubeModel()

    func resolveStreamURL(for track: Track) async -> URL? {
        guard let video = await firstVideo(for: track) else { return nil }
        return await audioURL(videoId: video.videoId)
    }

    private func firstVideo(for track: Track) async -> YTVideo? {
        let query = "\(track.artistName) \(track.title) audio"
        guard let response = try? await SearchResponse.sendThrowingRequest(youtubeModel: model, data: [.query: query]) else { return nil }
        return response.results.lazy.compactMap { $0 as? YTVideo }.first
    }

    private func audioURL(videoId: String) async -> URL? {
        guard let response = try? await VideoInfosWithDownloadFormatsResponse.sendThrowingRequest(youtubeModel: model, data: [.query: videoId]) else { return nil }
        let playable = response.downloadFormats
            .compactMap { $0 as? AudioOnlyFormat }
            .filter { $0.url != nil && ($0.mimeType ?? "").contains("mp4") }
        let best = playable.max { ($0.averageBitrate ?? 0) < ($1.averageBitrate ?? 0) }
        return best?.url ?? response.defaultFormats.first { ($0.mimeType ?? "").contains("mp4") }?.url
    }
}
