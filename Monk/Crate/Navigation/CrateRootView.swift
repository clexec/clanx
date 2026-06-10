import SwiftUI

struct CrateRootView: View {
    @EnvironmentObject private var player: PlayerManager
    @State private var showSearch = false
    @State private var showPlayer = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
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
            searchButton
        }
        .sheet(isPresented: $showPlayer) { PlayerScreen() }
        .sheet(isPresented: $showSearch) { SearchSheetView() }
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
        }
    }

    // Floating search — bottom-right, separate from tab bar
    private var searchButton: some View {
        Button { showSearch = true } label: {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
        }
        #if compiler(>=6.2)
        .glassEffect(in: .circle)
        #else
        .background(.ultraThinMaterial, in: Circle())
        #endif
        .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
        .padding(.trailing, 16)
        .padding(.bottom, player.currentTrack != nil ? 160 : 92)
    }
}

private struct SearchSheetView: View {
    @EnvironmentObject private var player: PlayerManager
    @StateObject private var model = CrateHomeViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            CrateColor.background.ignoresSafeArea()
            VStack(spacing: 16) {
                HStack {
                    SearchField(text: $model.query) { Task { await model.runSearch() } }
                    Button(bi("Отмена", "Cancel")) { dismiss() }
                        .foregroundStyle(CrateColor.secondaryText)
                        .font(.subheadline)
                }
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
                                    .onTapGesture {
                                        player.play(track, queue: model.results)
                                        dismiss()
                                    }
                                    .padding(.horizontal, 16)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                } else {
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 36))
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
