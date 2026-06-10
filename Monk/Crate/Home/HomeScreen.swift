import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject private var player: PlayerManager
    @StateObject private var model = CrateHomeViewModel()

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                Text(bi("Главная", "Home"))
                    .font(.title2.bold()).foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .center)

                SearchField(text: $model.query) { Task { await model.runSearch() } }

                FilterChips(selection: model.filter, titles: model.filters.map { bi($0.ru, $0.en) }) { index in
                    Task { await model.select(index) }
                }

                if model.isLoading {
                    HStack { Spacer(); ProgressView().tint(.white); Spacer() }
                        .padding(.top, 20)
                } else {
                    content
                }
            }
            .padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 170)
        }
        .background(CrateColor.background)
        .task { await model.loadIfNeeded() }
    }

    @ViewBuilder
    private var content: some View {
        if !model.query.isEmpty {
            if model.results.isEmpty {
                emptySearch
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(model.results) { track in
                        PlaylistTile(track: track)
                            .onTapGesture { player.play(track, queue: model.results) }
                    }
                }
            }
        } else {
            // Albums section
            if !model.albums.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text(bi("Альбомы", "Albums"))
                        .font(.title3.bold()).foregroundStyle(.white)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(model.albums) { album in
                                AlbumCard(album: album) {
                                    guard let first = album.tracks.first else { return }
                                    player.play(first, queue: Array(album.tracks.dropFirst()))
                                }
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                }
            }

            // Top tracks grid
            if !model.tiles.isEmpty {
                Text(bi("Популярные треки", "Top Tracks"))
                    .font(.title3.bold()).foregroundStyle(.white)
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(model.tiles) { track in
                        PlaylistTile(track: track)
                            .onTapGesture { player.play(track, queue: model.tiles) }
                    }
                }
            }

            // Recommended carousel
            if !model.recommended.isEmpty {
                Text(bi("Рекомендованные", "Recommended"))
                    .font(.title3.bold()).foregroundStyle(.white)
                RecommendedCarousel(tracks: model.recommended) { track in
                    player.play(track, queue: model.recommended)
                }
                .padding(.horizontal, -20)
            }
        }
    }

    private var emptySearch: some View {
        VStack(spacing: 12) {
            Spacer().frame(height: 40)
            Image(systemName: "magnifyingglass")
                .font(.system(size: 34)).foregroundStyle(CrateColor.secondaryText)
            Text(bi("Ничего не найдено", "No results"))
                .foregroundStyle(CrateColor.secondaryText).font(.subheadline)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct AlbumCard: View {
    let album: Album
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                AsyncImage(url: album.artworkURL) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    CrateColor.surface
                }
                .frame(width: 140, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(album.title)
                        .font(.caption.bold()).foregroundStyle(.white).lineLimit(1)
                    Text(album.artistName)
                        .font(.caption2).foregroundStyle(CrateColor.secondaryText).lineLimit(1)
                }
                .padding(.horizontal, 4)
            }
            .frame(width: 140)
            .padding(10)
            .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
