import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var discoverWeekly: [Track] = []
    @Published var releaseRadar: [Track] = []
    @Published var dailyMixes: [Playlist] = []
    @Published var popular: [Track] = []
    private let tracks = TrackRepository(api: ITunesAPIService())
    private let playlists = PlaylistRepository()

    func load() async {
        async let discover = tracks.recommendations(seed: "indie pop")
        async let radar = tracks.recommendations(seed: "new music")
        async let hits = tracks.trending()
        discoverWeekly = await discover
        releaseRadar = await radar
        popular = await hits
        dailyMixes = ["Electronic Focus", "Brown Sugar Soul", "Late Night Rock"].map { playlists.make(title: $0, tracks: popular.shuffled()) }
    }
}

final class DiscoverWeeklyViewModel: ObservableObject {}
final class ReleaseRadarViewModel: ObservableObject {}
final class RecentlyPlayedViewModel: ObservableObject {}
