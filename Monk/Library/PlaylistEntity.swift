import Foundation
import SwiftData

@Model
final class PlaylistEntity {
    @Attribute(.unique) var id: String
    var title: String
    var createdAt: Date
    @Relationship(deleteRule: .nullify) var tracks: [TrackEntity]

    init(id: String = UUID().uuidString, title: String, tracks: [TrackEntity] = [], createdAt: Date = .now) {
        self.id = id
        self.title = title
        self.tracks = tracks
        self.createdAt = createdAt
    }
}
