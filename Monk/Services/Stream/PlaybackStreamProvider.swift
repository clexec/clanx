import Foundation

@MainActor
final class PlaybackStreamProvider {
    private let resolvers: [StreamResolving]
    private var cache: [Int: URL] = [:]

    init(resolvers: [StreamResolving] = PlaybackStreamProvider.makeResolvers()) {
        self.resolvers = resolvers
    }

    func streamURL(for track: Track) async -> URL? {
        if let cached = cache[track.id] { return cached }
        for resolver in resolvers {
            if let url = await resolver.resolveStreamURL(for: track) {
                cache[track.id] = url
                return url
            }
        }
        return track.previewURL
    }

    private static func makeResolvers() -> [StreamResolving] {
        PlaybackConfig.preferredSources.compactMap { source -> StreamResolving? in
            switch source {
            case .youtube: return YouTubeStreamResolver()
            case .yandex: return YandexStreamResolver()
            case .preview: return nil
            }
        }
    }
}
