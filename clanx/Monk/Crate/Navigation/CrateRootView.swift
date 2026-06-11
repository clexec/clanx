import SwiftUI

private enum RootTab: Int, CaseIterable {
    case home, favorites, profile

    var title: String {
        switch self {
        case .home:      return "Главная"
        case .favorites: return "Избранное"
        case .profile:   return "Профиль"
        }
    }

    var icon: String {
        switch self {
        case .home:      return "house.fill"
        case .favorites: return "heart.fill"
        case .profile:   return "person.fill"
        }
    }
}

struct CrateRootView: View {
    @EnvironmentObject private var player: PlayerManager
    @State private var selectedTab: RootTab = .home
    @State private var showSearch = false
    @State private var showPlayer = false

    var body: some View {
        ZStack {
            // Screen content — all screens kept alive via opacity
            HomeScreen()
                .opacity(selectedTab == .home ? 1 : 0)
                .allowsHitTesting(selectedTab == .home)

            CrateFavoritesScreen()
                .opacity(selectedTab == .favorites ? 1 : 0)
                .allowsHitTesting(selectedTab == .favorites)

            CrateProfileScreen()
                .opacity(selectedTab == .profile ? 1 : 0)
                .allowsHitTesting(selectedTab == .profile)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomBar
        }
        .sheet(isPresented: $showPlayer) { PlayerScreen() }
        .sheet(isPresented: $showSearch) { SearchSheetView() }
    }

    // MARK: - Bottom bar

    private var bottomBar: some View {
        VStack(spacing: 0) {
            // Mini player above the bar (tap to open full player)
            if player.currentTrack != nil {
                MiniPlayerBar()
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
                    .onTapGesture { showPlayer = true }
            }

            // Tab row: [capsule with 3 tabs] [search circle]
            HStack(spacing: 12) {
                // Left capsule — 3 tabs joined
                HStack(spacing: 0) {
                    ForEach(RootTab.allCases, id: \.rawValue) { tab in
                        tabButton(tab)
                    }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 0.5))

                // Right circle — search, same row, visually separated
                Button { showSearch = true } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 54, height: 54)
                        .background(.ultraThinMaterial, in: Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.12), lineWidth: 0.5))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 28)
            .background(
                LinearGradient(
                    colors: [.black.opacity(0), .black.opacity(0.92)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea(edges: .bottom)
            )
        }
    }

    // MARK: - Single tab button

    private func tabButton(_ tab: RootTab) -> some View {
        let selected = selectedTab == tab
        return Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 17, weight: selected ? .bold : .regular))
                Text(tab.title)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(selected ? .white : CrateColor.secondaryText)
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .background(selected ? Color.white.opacity(0.12) : Color.clear, in: Capsule())
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25), value: selected)
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
