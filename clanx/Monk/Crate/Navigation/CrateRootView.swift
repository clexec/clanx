import SwiftUI

struct CrateRootView: View {
    @EnvironmentObject private var player: PlayerManager
    @State private var showSearch = false
    @State private var showPlayer = false

    var body: some View {
        tabContent
            .sheet(isPresented: $showPlayer) { PlayerScreen() }
            .sheet(isPresented: $showSearch) { SearchSheetView() }
    }

    // MARK: - Tab content

    @ViewBuilder
    private var tabContent: some View {
        #if compiler(>=6.2)
        nativeTabView
        #else
        fallbackTabView
        #endif
    }

    // MARK: - iOS 26 native TabView (glass bar) + search in same accessory row

    #if compiler(>=6.2)
    @ViewBuilder
    private var nativeTabView: some View {
        TabView {
            Tab("Главная",   systemImage: "house.fill")   { HomeScreen() }
            Tab("Избранное", systemImage: "heart.fill")   { CrateFavoritesScreen() }
            Tab("Профиль",   systemImage: "person.fill")  { CrateProfileScreen() }
        }
        // tabViewBottomAccessory sits in the same visual strip as the tab bar
        .tabViewBottomAccessory {
            HStack(spacing: 0) {
                // Mini player (only when track is active) — takes all available space
                if player.currentTrack != nil {
                    MiniPlayerBar()
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .onTapGesture { showPlayer = true }
                        .layoutPriority(1)
                }

                Spacer(minLength: 0)

                // Search circle — always visible, right side, same row as mini player
                Button { showSearch = true } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .glassEffect(in: .circle)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 12)
            }
        }
    }
    #endif

    // MARK: - Fallback for Xcode 16

    private var fallbackTabView: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView {
                HomeScreen().tabItem           { Label("Главная",   systemImage: "house.fill")  }
                CrateFavoritesScreen().tabItem { Label("Избранное", systemImage: "heart.fill")  }
                CrateProfileScreen().tabItem   { Label("Профиль",   systemImage: "person.fill") }
            }

            // Fallback: floating search circle above tab bar
            Button { showSearch = true } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .buttonStyle(.plain)
            .padding(.trailing, 16)
            .padding(.bottom, player.currentTrack != nil ? 148 : 84)
        }
    }
}

// MARK: - Search sheet

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
                        .foregroundStyle(CrateColor.secondaryText).font(.subheadline)
                }
                .padding(.horizontal, 16).padding(.top, 16)

                if model.isLoading {
                    Spacer(); ProgressView().tint(.white); Spacer()
                } else if !model.results.isEmpty {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(model.results) { track in
                                PlaylistTile(track: track)
                                    .onTapGesture { player.play(track, queue: model.results); dismiss() }
                                    .padding(.horizontal, 16)
                            }
                        }.padding(.bottom, 20)
                    }
                } else {
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 36)).foregroundStyle(CrateColor.secondaryText)
                    Text(bi("Введите запрос", "Type to search"))
                        .foregroundStyle(CrateColor.secondaryText).font(.subheadline)
                    Spacer()
                }
            }
        }
        .onChange(of: model.query) { _, _ in Task { await model.runSearch() } }
    }
}
