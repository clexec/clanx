import Foundation
import SwiftData

@MainActor
final class LibraryStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func toggleFavorite(_ track: Track) {
        if let existing = entity(for: track.id) {
            existing.isFavorite.toggle()
        } else {
            let entity = TrackEntity(track: track, isFavorite: true)
            context.insert(entity)
        }
        try? context.save()
    }

    func markPlayed(_ track: Track) {
        let entity = entity(for: track.id) ?? {
            let created = TrackEntity(track: track)
            context.insert(created)
            return created
        }()
        entity.lastPlayedAt = .now
        try? context.save()
    }

    func isFavorite(_ trackId: Int) -> Bool {
        entity(for: trackId)?.isFavorite ?? false
    }

    func favorites() -> [Track] {
        let descriptor = FetchDescriptor<TrackEntity>(
            predicate: #Predicate { $0.isFavorite },
            sortBy: [SortDescriptor(\.title)]
        )
        return (try? context.fetch(descriptor))?.map(\.asTrack) ?? []
    }

    func recentlyPlayed(limit: Int = 30) -> [Track] {
        var descriptor = FetchDescriptor<TrackEntity>(
            predicate: #Predicate { $0.lastPlayedAt != nil },
            sortBy: [SortDescriptor(\.lastPlayedAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return (try? context.fetch(descriptor))?.map(\.asTrack) ?? []
    }

    private func entity(for trackId: Int) -> TrackEntity? {
        let descriptor = FetchDescriptor<TrackEntity>(predicate: #Predicate { $0.trackId == trackId })
        return try? context.fetch(descriptor).first
    }
}
