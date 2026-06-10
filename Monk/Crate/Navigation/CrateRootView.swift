import SwiftUI

struct CrateRootView: View {
    @EnvironmentObject private var player: PlayerManager
    @State private var showPlayer = false

    var body: some View {
        tabContent
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if player.currentTrack != nil {
                    MiniPlayerBar()
                        .padding(.horizontal, 10)
                        .padding(.bottom, 6)
                        .padding(.top, 4)
                        .onTapGesture { showPlayer = true }
                }
            }
            .sheet(isPresented: $showPlayer) { PlayerScreen() }
    }

    @ViewBuilder
    private var tabContent: some View {
        #if compiler(>=6.2)
        nativeTabView
        #else
        fallbackTabView
        #endif
    }

    #if compiler(>=6.2)
    @ViewBuilder
    private var nativeTabView: some View {
        TabView {
            // Grouped section — appears as one connected glass pill
            TabSection {
                Tab("Главная", systemImage: "house.fill") {
                    HomeScreen()
                }
                Tab("Избранное", systemImage: "heart.fill") {
                    CrateFavoritesScreen()
                }
                Tab("Профиль", systemImage: "person.fill") {
                    CrateProfileScreen()
                }
            }
            // Search — standalone, separated from the group
            Tab("Поиск", systemImage: "magnifyingglass") {
                SearchTabView()
            }
        }
    }
    #endif

    private var fallbackTabView: some View {
        TabView {
            HomeScreen()
                .tabItem { Label("Главная", systemImage: "house.fill") }
            CrateFavoritesScreen()
                .tabItem { Label("Избранное", systemImage: "heart.fill") }
            CrateProfileScreen()
                .tabItem { Label("Профиль", systemImage: "person.fill") }
            SearchTabView()
                .tabItem { Label("Поиск", systemImage: "magnifyingglass") }
        }
    }

}

// Full search screen — lives as a tab, not a sheet
private struct SearchTabView: View {
    @EnvironmentObject private var player: PlayerManager
    @StateObject private var model = CrateHomeViewModel()

    var body: some View {
        ZStack {
            CrateColor.background.ignoresSafeArea()
            VStack(spacing: 16) {
                SearchField(text: $model.query) { Task { await model.runSearch() } }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                if model.isLoading {
                    Spacer()
                    ProgressView().tint(.white)
                    Spacer()
                } else if !model.results.isEmpty {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(model.results) { track in
                                PlaylistTile(track: track)
                                    .onTapGesture { player.play(track, queue: model.results) }
                                    .padding(.horizontal, 16)
                            }
                        }
                        .padding(.bottom, 100)
                    }
                } else {
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 44))
                        .foregroundStyle(CrateColor.secondaryText)
                    Text(bi("Введите запрос", "Type to search"))
                        .foregroundStyle(CrateColor.secondaryText)
                        .font(.subheadline)
                    Spacer()
                }
            }
        }
        .onChange(of: model.query) { _, _ in
            Task { await model.runSearch() }
        }
    }
}
