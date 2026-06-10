import Foundation

protocol StreamResolving {
    var source: MusicSource { get }
    func resolveStreamURL(for track: Track) async -> URL?
}
