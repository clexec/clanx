import Foundation
// YouTubeKit inlined

struct YouTubeStreamResolver: StreamResolving {
    let source: MusicSource = .youtube
    private let model = YouTubeModel()

    func resolveStreamURL(for track: Track) async -> URL? {
        guard let videoId = await findVideoId(for: track) else { return nil }
        return await audioURL(videoId: videoId)
    }

    private func findVideoId(for track: Track) async -> String? {
        let query = "\(track.artistName) \(track.title) full audio"
        guard let response = try? await SearchResponse.sendThrowingRequest(
            youtubeModel: model,
            data: [.query: query]
        ) else { return nil }
        return response.results.lazy.compactMap { $0 as? YTVideo }.first?.videoId
    }

    private func audioURL(videoId: String) async -> URL? {
        // .query key accepts videoId — validated by .videoIdValidator in this response type
        guard let response = try? await VideoInfosWithDownloadFormatsResponse.sendThrowingRequest(
            youtubeModel: model,
            data: [.query: videoId]
        ) else { return nil }

        // Prefer audio-only mp4, highest bitrate
        let audioFormats = response.downloadFormats
            .compactMap { $0 as? AudioOnlyFormat }
            .filter { $0.url != nil }

        if let best = audioFormats.max(by: { ($0.averageBitrate ?? 0) < ($1.averageBitrate ?? 0) }) {
            return best.url
        }

        // Fallback: any default mp4 format
        return response.defaultFormats.first { ($0.mimeType ?? "").contains("mp4") }?.url
    }
}
