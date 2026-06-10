import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject private var player: PlayerManager
    @StateObject private var model = CrateHomeViewModel()

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                Text(bi("Главная", "Home")).font(.title2.bold()).foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                SearchField(text: $model.query) { Task { await model.runSearch() } }
                FilterChips(selection: model.filter, titles: model.filters.map { bi($0.ru, $0.en) }) { index in
                    Task { await model.select(index) }
                }
                content
            }
            .padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 170)
        }
        .background(CrateColor.background)
        .task { await model.loadIfNeeded() }
    }

    @ViewBuilder
    private var content: some View {
        if !model.query.isEmpty && !model.results.isEmpty {
            LazyVStack(spacing: 10) {
                ForEach(model.results) { track in
                    PlaylistTile(track: track)
                        .onTapGesture { player.play(track, queue: model.results) }
                }
            }
        } else {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(model.tiles) { track in
                    PlaylistTile(track: track)
                        .onTapGesture { player.play(track, queue: model.tiles) }
                }
            }
            Text(bi("Рекомендованные треки", "Recommended")).font(.title3.bold()).foregroundStyle(.white)
            RecommendedCarousel(tracks: model.recommended) { track in
                player.play(track, queue: model.recommended)
            }
            .padding(.horizontal, -20)
        }
    }
}
