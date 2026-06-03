import Foundation

struct Track: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let artistName: String
    let albumName: String
    let coverURL: String?
    let audioURL: String?
    let durationSeconds: Int

    var durationText: String {
        let minutes = durationSeconds / 60
        let seconds = durationSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}


struct Album: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let artistName: String
    let coverURL: String?
    let year: Int?
    let tracks: [Track]
}


struct Artist: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let imageURL: String?
    let genres: [String]
    let topTracks: [Track]
}


struct Playlist: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let subtitle: String
    let coverURL: String?
    let tracks: [Track]
}


struct Genre: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let colorSeed: String
}
