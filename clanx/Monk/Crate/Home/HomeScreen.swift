import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject private var player: PlayerManager
    @StateObject private var model = CrateHomeViewModel()

    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {

                Text(bi("Главная", "Home"))
                    .font(.custom("DelaGothicOne-Regular", size: 28))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)

                SearchField(text: $model.query) { Task { await model.runSearch() } }

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

    // MARK: - Filter chips (Liquid Glass)

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(model.filters.indices, id: \.self) { index in
                    let active = model.filter == index
                    Button { Task { await model.select(index) } } label: {
                        Text(bi(model.filters[index].ru, model.filters[index].en))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(active ? .black : .white)
                            .padding(.horizontal, 18).padding(.vertical, 9)
                            .background(active ? Color.white : Color.clear, in: Capsule())
                            .glassEffect(.regular, in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .animation(.spring(response: 0.25, dampingFraction: 0.7), value: active)
                }
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: - Main content

    @ViewBuilder
    private var mainContent: some View {
        if !model.tiles.isEmpty {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(model.tiles) { track in
                    homeCard(track: track)
                        .onTapGesture { player.play(track, queue: model.tiles) }
                }
            }
        }

        if !model.recommended.isEmpty {
            artistCarousel(
                title: bi("Рекомендованные треки", "Recommended Tracks"),
                tracks: model.recommended
            )
        }

        if !model.lilPeep.isEmpty {
            artistCarousel(title: "Lil Peep", tracks: model.lilPeep)
        }

        if !model.morgenshtern.isEmpty {
            artistCarousel(title: "Моргенштерн", tracks: model.morgenshtern)
        }

        if !model.albums.isEmpty {
            albumCarousel
        }
    }

    // MARK: - Artist carousel

    private func artistCarousel(title: String, tracks: [Track]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.custom("DelaGothicOne-Regular", size: 20))
                .foregroundStyle(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(tracks) { track in
                        VStack(alignment: .leading, spacing: 8) {
                            CoverArtView(url: track.artworkURL, corner: 14)
                                .frame(width: 150, height: 150)
                            Text(track.title)
                                .font(.caption.bold()).foregroundStyle(.white)
                                .lineLimit(1).frame(width: 150)
                            Text(track.artistName)
                                .font(.caption2).foregroundStyle(CrateColor.secondaryText)
                                .lineLimit(1).frame(width: 150)
                        }
                        .onTapGesture { player.play(track, queue: tracks) }
                    }
                }
                .padding(.horizontal, 1)
            }
            .padding(.horizontal, -16).padding(.leading, 16)
        }
    }

    // MARK: - Albums carousel

    private var albumCarousel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(bi("Альбомы", "Albums"))
                .font(.custom("DelaGothicOne-Regular", size: 20))
                .foregroundStyle(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(model.albums) { album in
                        VStack(alignment: .leading, spacing: 8) {
                            CoverArtView(url: album.artworkURL, corner: 14)
                                .frame(width: 150, height: 150)
                            Text(album.title)
                                .font(.caption.bold()).foregroundStyle(.white)
                                .lineLimit(1).frame(width: 150)
                            Text(album.artistName)
                                .font(.caption2).foregroundStyle(CrateColor.secondaryText)
                                .lineLimit(1).frame(width: 150)
                        }
                        .onTapGesture {
                            if let f = album.tracks.first { player.play(f, queue: album.tracks) }
                        }
                    }
                }
                .padding(.horizontal, 1)
            }
            .padding(.horizontal, -16).padding(.leading, 16)
        }
    }

    // MARK: - Search results

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

    // MARK: - Home card

    private func homeCard(track: Track) -> some View {
        HStack(spacing: 10) {
            CoverArtView(url: track.artworkURL, corner: 10).frame(width: 52, height: 52)
            VStack(alignment: .leading, spacing: 3) {
                Text(track.title).font(.caption.bold()).foregroundStyle(.white).lineLimit(2)
                Text(track.artistName).font(.caption2).foregroundStyle(CrateColor.secondaryText).lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
