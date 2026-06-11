import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject private var player: PlayerManager
    @StateObject private var model = CrateHomeViewModel()

    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {

                // Title
                Text(bi("Главная", "Home"))
                    .font(.custom("DelaGothicOne-Regular", size: 28))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)

                // Search bar
                SearchField(text: $model.query) { Task { await model.runSearch() } }

                // Filter chips with glass
                filterChips

                if model.isLoading {
                    HStack { Spacer(); ProgressView().tint(.white); Spacer() }.padding(.top, 30)
                } else if !model.query.isEmpty {
                    searchResults
                } else {
                    mainContent
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 200)
        }
        .background(CrateColor.background)
        .task { await model.loadIfNeeded() }
    }

    // MARK: Filter chips
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(model.filters.indices, id: \.self) { index in
                    let active = model.filter == index
                    Text(bi(model.filters[index].ru, model.filters[index].en))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(active ? .black : .white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 9)
                        .background {
                            if active {
                                Capsule().fill(.white)
                            } else {
                                Capsule().fill(.clear)
                            }
                        }
                        .crateGlass(Capsule())
                        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: active)
                        .onTapGesture { Task { await model.select(index) } }
                }
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: Main content
    @ViewBuilder
    private var mainContent: some View {
        // 2-column grid of top tracks (matches screenshot)
        if !model.tiles.isEmpty {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(model.tiles) { track in
                    homeCard(track: track)
                        .onTapGesture { player.play(track, queue: model.tiles) }
                }
            }
        }

        // Recommended carousel
        if !model.recommended.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text(bi("Рекомендованные треки", "Recommended Tracks"))
                    .font(.custom("DelaGothicOne-Regular", size: 20)).foregroundStyle(.white)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(model.recommended) { track in
                            CoverArtView(url: track.artworkURL, corner: 14)
                                .frame(width: 160, height: 160)
                                .onTapGesture { player.play(track, queue: model.recommended) }
                        }
                    }
                    .padding(.horizontal, 1)
                }
                .padding(.horizontal, -16)
                .padding(.leading, 16)
            }
        }
    }

    // MARK: Search results
    @ViewBuilder
    private var searchResults: some View {
        if model.results.isEmpty {
            VStack(spacing: 12) {
                Spacer().frame(height: 40)
                Image(systemName: "magnifyingglass").font(.system(size: 34)).foregroundStyle(CrateColor.secondaryText)
                Text(bi("Ничего не найдено", "No results")).foregroundStyle(CrateColor.secondaryText).font(.subheadline)
            }.frame(maxWidth: .infinity)
        } else {
            LazyVStack(spacing: 10) {
                ForEach(model.results) { track in
                    PlaylistTile(track: track)
                        .onTapGesture { player.play(track, queue: model.results) }
                }
            }
        }
    }

    // Home card — artwork left + text right, glass background
    private func homeCard(track: Track) -> some View {
        HStack(spacing: 10) {
            CoverArtView(url: track.artworkURL, corner: 10)
                .frame(width: 52, height: 52)
            VStack(alignment: .leading, spacing: 3) {
                Text(track.title)
                    .font(.caption.bold()).foregroundStyle(.white).lineLimit(2)
                Text(track.artistName)
                    .font(.caption2).foregroundStyle(CrateColor.secondaryText).lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .crateGlass(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
