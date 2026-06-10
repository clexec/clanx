import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject private var player: PlayerManager
    @State private var showSearch = false
    @State private var selectedFilter = "Все"

    private let filters = ["Все", "Музыка", "Подкасты", "Аудиокниги"]
    private let gridColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                // Title
                Text("Главная")
                    .font(.delaTitle)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)

                // Tappable search bar
                searchBar

                // Filter chips
                filterChips

                // Quick access 2-column grid
                if !viewModel.popular.isEmpty {
                    quickGrid
                }

                // Recommended tracks carousel
                if !viewModel.discoverWeekly.isEmpty {
                    recommendedSection
                }

                // New releases carousel
                if !viewModel.releaseRadar.isEmpty {
                    musicCarousel("Новинки", tracks: viewModel.releaseRadar)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .background(Color.black.ignoresSafeArea())
        .navigationBarHidden(true)
        .task { await viewModel.load() }
        .sheet(isPresented: $showSearch) {
            SearchView()
        }
    }

    // MARK: - Search bar (tappable, opens SearchView)

    private var searchBar: some View {
        Button { showSearch = true } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 32, height: 32)
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
                Text("Поиск")
                    .font(.body)
                    .foregroundStyle(ColorPalette.textSecondary)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(ColorPalette.elevated.opacity(0.85), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Filter chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(filters, id: \.self) { filter in
                    Button {
                        withAnimation(.spring(response: 0.28)) { selectedFilter = filter }
                    } label: {
                        Text(filter)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(selectedFilter == filter ? .black : .white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                selectedFilter == filter ? Color.white : ColorPalette.elevated.opacity(0.7),
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Quick access 2-column grid

    private var quickGrid: some View {
        let items = filteredTracks.prefix(6)
        return LazyVGrid(columns: gridColumns, spacing: 10) {
            ForEach(Array(items), id: \.id) { track in
                QuickGridCard(track: track) {
                    player.play(track, queue: filteredTracks)
                }
            }
        }
    }

    private var filteredTracks: [Track] {
        switch selectedFilter {
        case "Музыка":      return viewModel.popular
        case "Подкасты":    return viewModel.discoverWeekly
        case "Аудиокниги":  return viewModel.releaseRadar
        default:
            var merged = [Track]()
            for (a, b) in zip(viewModel.popular, viewModel.discoverWeekly) { merged += [a, b] }
            return merged
        }
    }

    // MARK: - Recommended horizontal carousel

    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Рекомендованные треки")
                .font(.delaTitle3)
                .foregroundStyle(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.discoverWeekly.prefix(8), id: \.id) { track in
                        Button {
                            player.play(track, queue: viewModel.discoverWeekly)
                        } label: {
                            RemoteArtworkView(url: track.artworkURL, size: 160)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Generic music carousel

    private func musicCarousel(_ title: String, tracks: [Track]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.delaTitle3)
                .foregroundStyle(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(tracks.prefix(10), id: \.id) { track in
                        AlbumCardView(
                            title: track.title,
                            subtitle: track.artistName,
                            artworkURL: track.artworkURL
                        )
                        .onTapGesture { player.play(track, queue: tracks) }
                    }
                }
            }
        }
    }
}

// MARK: - Quick grid card (2-column item with thumbnail on left)

private struct QuickGridCard: View {
    let track: Track
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                RemoteArtworkView(url: track.artworkURL, size: 48)
                VStack(alignment: .leading, spacing: 3) {
                    Text(track.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    Text(track.artistName)
                        .font(.caption)
                        .foregroundStyle(ColorPalette.textSecondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ColorPalette.elevated.opacity(0.65), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// Keep legacy typealiases so other files that reference them still compile
typealias DiscoverWeeklyView  = HomeView
typealias ReleaseRadarView    = HomeView
typealias DailyMixView        = HomeView
typealias RecentlyPlayedView  = HomeView
struct RecommendationCardView: View {
    let track: Track
    var body: some View { AlbumCardView(title: track.title, subtitle: track.artistName, artworkURL: track.artworkURL) }
}
