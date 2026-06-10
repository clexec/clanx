import Foundation
// YouTubeKit inlined

struct YouTubeStreamResolver: StreamResolving {
    let source: MusicSource = .youtube
    private let model = YouTubeModel()

    func resolveStreamURL(for track: Track) async -> URL? {
        guard let videoId = await findVideoId(for: track) else { return nil }
        return await fullAudioURL(videoId: videoId)
    }

    // Step 1: search for the track, get videoId
    private func findVideoId(for track: Track) async -> String? {
        let query = "\(track.artistName) \(track.title) full song audio"
        guard let response = try? await SearchResponse.sendThrowingRequest(
            youtubeModel: model,
            data: [.query: query]
        ) else { return nil }
        return response.results.lazy.compactMap { $0 as? YTVideo }.first?.videoId
    }

    // Step 2: fetch full streaming formats using .videoId (NOT .query — that gives 30s preview)
    private func fullAudioURL(videoId: String) async -> URL? {
        // Primary: streaming infos — direct playback URLs, full duration
        if let url = await streamingInfoURL(videoId: videoId) { return url }
        // Fallback: download formats
        return await downloadFormatURL(videoId: videoId)
    }

    private func streamingInfoURL(videoId: String) async -> URL? {
        guard let response = try? await VideoInfosWithStreamingInfosResponse.sendThrowingRequest(
            youtubeModel: model,
            data: [.videoId: videoId]
        ) else { return nil }

        let formats = response.streamingInfos
            .compactMap { $0 as? AudioOnlyFormat }
            .filter { $0.url != nil }
        return formats.max { ($0.averageBitrate ?? 0) < ($1.averageBitrate ?? 0) }?.url
    }

    private func downloadFormatURL(videoId: String) async -> URL? {
        guard let response = try? await VideoInfosWithDownloadFormatsResponse.sendThrowingRequest(
            youtubeModel: model,
            data: [.videoId: videoId]  // .videoId — not .query
        ) else { return nil }

        let formats = response.downloadFormats
            .compactMap { $0 as? AudioOnlyFormat }
            .filter { $0.url != nil }
        return formats.max { ($0.averageBitrate ?? 0) < ($1.averageBitrate ?? 0) }?.url
    }
}
