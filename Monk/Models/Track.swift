import Foundation

struct Track: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let artistName: String
    let albumTitle: String
    let artworkURL: URL?
    let previewURL: URL?
    let durationMillis: Int
    let genre: String
    let releaseDate: Date?

    var durationText: String {
        TimeFormatHelper.format(milliseconds: durationMillis)
    }
}

struct ITunesTrackDTO: Decodable {
    let trackId: Int?
    let trackName: String?
    let artistName: String?
    let collectionName: String?
    let artworkUrl100: String?
    let previewUrl: String?
    let trackTimeMillis: Int?
    let primaryGenreName: String?
    let releaseDate: String?

    func toTrack() -> Track? {
        guard let id = trackId, let title = trackName, let artist = artistName else { return nil }
        let artwork = artworkUrl100.flatMap { URL(string: $0.replacingOccurrences(of: "100x100bb", with: "600x600bb")) }
        let preview = previewUrl.flatMap(URL.init(string:))
        let date = releaseDate.flatMap { ISO8601DateFormatter().date(from: $0) }
        return Track(id: id, title: title, artistName: artist, albumTitle: collectionName ?? "Single", artworkURL: artwork, previewURL: preview, durationMillis: trackTimeMillis ?? 30_000, genre: primaryGenreName ?? "Music", releaseDate: date)
    }
}

struct ITunesSearchResponse: Decodable {
    let results: [ITunesTrackDTO]
}
