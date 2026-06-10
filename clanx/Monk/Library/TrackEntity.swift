import Foundation
import SwiftData

@Model
final class TrackEntity {
    @Attribute(.unique) var trackId: Int
    var title: String
    var artistName: String
    var albumTitle: String
    var artworkURLString: String?
    var previewURLString: String?
    var durationMillis: Int
    var genre: String
    var releaseDate: Date?
    var isFavorite: Bool
    var lastPlayedAt: Date?

    init(track: Track, isFavorite: Bool = false, lastPlayedAt: Date? = nil) {
        trackId = track.id
        title = track.title
        artistName = track.artistName
        albumTitle = track.albumTitle
        artworkURLString = track.artworkURL?.absoluteString
        previewURLString = track.previewURL?.absoluteString
        durationMillis = track.durationMillis
        genre = track.genre
        releaseDate = track.releaseDate
        self.isFavorite = isFavorite
        self.lastPlayedAt = lastPlayedAt
    }

    var asTrack: Track {
        Track(
            id: trackId,
            title: title,
            artistName: artistName,
            albumTitle: albumTitle,
            artworkURL: artworkURLString.flatMap { URL(string: $0) },
            previewURL: previewURLString.flatMap { URL(string: $0) },
            durationMillis: durationMillis,
            genre: genre,
            releaseDate: releaseDate
        )
    }
}
