import Foundation
import Combine

@MainActor
final class CrateHomeViewModel: ObservableObject {
    @Published var query = ""
    @Published var filter = 0
    @Published var recommended: [Track] = []
    @Published var tiles: [Track] = []
    @Published var results: [Track] = []
    @Published var isLoading = false

    let filters: [(ru: String, en: String, seed: String)] = [
        ("Все", "All", "top hits 2026"),
        ("Музыка", "Music", "pop hits"),
        ("Подкасты", "Podcasts", "talk"),
        ("Аудиокниги", "Audiobooks", "soundtrack")
    ]

    private let tracks = TrackRepository(api: ITunesAPIService())
    private let search = SearchRepository(api: ITunesAPIService())

    func loadIfNeeded() async {
        guard recommended.isEmpty else { return }
        await reload(seed: filters[filter].seed)
    }

    func select(_ index: Int) async {
        filter = index
        await reload(seed: filters[index].seed)
    }

    func runSearch() async {
        let term = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else { results = []; return }
        results = await search.search(term)
    }

    private func reload(seed: String) async {
        isLoading = true
        let loaded = await tracks.recommendations(seed: seed)
        recommended = loaded
        tiles = Array(loaded.prefix(6))
        isLoading = false
    }
}
