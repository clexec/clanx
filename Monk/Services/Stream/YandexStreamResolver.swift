import Foundation
import YMAPI

struct YandexStreamResolver: StreamResolving {
    let source: MusicSource = .yandex
    private let client: YMClient

    init?() {
        guard let client = YandexMusicClient.shared.client else { return nil }
        self.client = client
    }

    func resolveStreamURL(for track: Track) async -> URL? {
        guard let match = await firstTrack(for: track) else { return nil }
        guard let link = await downloadLink(for: match) else { return nil }
        return URL(string: link)
    }

    private func firstTrack(for track: Track) async -> YMAPI.Track? {
        let query = "\(track.artistName) \(track.title)"
        return await withCheckedContinuation { continuation in
            client.search(text: query, noCorrect: false, type: .track, page: 0, includeBestPlaylists: false) { result in
                continuation.resume(returning: (try? result.get())?.tracks?.results.first)
            }
        }
    }

    private func downloadLink(for track: YMAPI.Track) async -> String? {
        await withCheckedContinuation { continuation in
            track.getDownloadLink(codec: .mp3, bitrate: .kbps_320) { result in
                continuation.resume(returning: try? result.get())
            }
        }
    }
}
