import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject private var player: PlayerManager
    @EnvironmentObject private var persistence: PersistenceController
    @EnvironmentObject private var auth: AuthenticationManager

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Доброе утро"
        case 12..<17: return "Добрый день"
        case 17..<23: return "Добрый вечер"
        default:      return "Доброй ночи"
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                header
                if !persistence.recentlyPlayed.isEmpty {
                    musicSection("Недавно слушали", tracks: persistence.recentlyPlayed)
                }
                musicSection("Открытия недели", tracks: viewModel.discoverWeekly)
                musicSection("Новые релизы", tracks: viewModel.releaseRadar)
                mixSection
                musicSection("Сейчас в тренде", tracks: viewModel.popular)
            }
            .padding(.horizontal, UIConstants.horizontalPadding)
            .padding(.bottom, 130)
        }
        .background(Color.black.ignoresSafeArea())
        .task { await viewModel.load() }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                if let name = auth.currentUser?.displayName, !name.isEmpty {
                    Text(name)
                        .font(.callout)
                        .foregroundStyle(ColorPalette.textSecondary)
                }
            }
            Spacer()
            NavigationLink {
                ProfileView()
                    .environmentObject(auth)
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [ColorPalette.accent, ColorPalette.secondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 38, height: 38)
                    if let name = auth.currentUser?.displayName, !name.isEmpty {
                        Text(String(name.prefix(1)).uppercased())
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Music section

    private func musicSection(_ title: String, tracks: [Track]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(tracks) { track in
                        AlbumCardView(
                            title: track.title,
                            subtitle: track.artistName,
                            artworkURL: track.artworkURL
                        )
                        .onTapGesture {
                            let q = tracks.filter { $0.id != track.id }
                            player.play(track, queue: q)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Daily Mixes

    private var mixSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Дейли-миксы")
                .font(.title3.bold())
                .foregroundStyle(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(viewModel.dailyMixes) { mix in
                        PlaylistCardView(
                            title: mix.title,
                            subtitle: mix.subtitle,
                            artworkURL: mix.artworkURL
                        )
                    }
                }
            }
        }
    }
}

typealias DiscoverWeeklyView = HomeView
typealias ReleaseRadarView   = HomeView
typealias DailyMixView       = HomeView
typealias RecentlyPlayedView = HomeView
struct RecommendationCardView: View {
    let track: Track
    var body: some View { AlbumCardView(title: track.title, subtitle: track.artistName, artworkURL: track.artworkURL) }
}
