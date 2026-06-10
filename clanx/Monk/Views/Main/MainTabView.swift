import SwiftUI

enum AppTab: Int, CaseIterable {
    case home, favorites, profile

    var icon: String {
        switch self {
        case .home:      return "house.fill"
        case .favorites: return "heart.fill"
        case .profile:   return "person.fill"
        }
    }

    var label: String {
        switch self {
        case .home:      return "Главная"
        case .favorites: return "Избранное"
        case .profile:   return "Профиль"
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home
    @State private var showSearch = false
    @EnvironmentObject private var player: PlayerManager

    var body: some View {
        ZStack {
            // Keep all tabs alive so navigation state is preserved
            NavigationStack { HomeView() }
                .opacity(selectedTab == .home ? 1 : 0)
                .allowsHitTesting(selectedTab == .home)
            NavigationStack { LibraryView() }
                .opacity(selectedTab == .favorites ? 1 : 0)
                .allowsHitTesting(selectedTab == .favorites)
            NavigationStack { ProfileView() }
                .opacity(selectedTab == .profile ? 1 : 0)
                .allowsHitTesting(selectedTab == .profile)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomOverlay
        }
        .sheet(isPresented: $showSearch) {
            SearchView()
        }
    }

    // MARK: - Bottom overlay (mini player + custom tab bar)

    private var bottomOverlay: some View {
        VStack(spacing: 8) {
            if player.currentTrack != nil {
                MiniPlayerView()
                    .padding(.horizontal, 12)
            }
            customTabBar
        }
        .padding(.top, 8)
        .padding(.bottom, 28)
        .background(Color.clear)
    }

    // MARK: - Custom tab bar

    private var customTabBar: some View {
        HStack(spacing: 14) {
            // Left glass capsule — 3 tabs
            HStack(spacing: 2) {
                ForEach(AppTab.allCases, id: \.rawValue) { tab in
                    tabItem(tab)
                }
            }
            .padding(5)
            .crateGlass(Capsule())

            // Right glass circle — search, visually separate
            Button { showSearch = true } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 54, height: 54)
            }
            .buttonStyle(.plain)
            .crateGlass(Circle())
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Single tab item

    private func tabItem(_ tab: AppTab) -> some View {
        let selected = selectedTab == tab
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: tab.icon)
                    .font(.system(size: 18, weight: selected ? .bold : .regular))
                Text(tab.label)
                    .font(.dela(10))
            }
            .foregroundStyle(selected ? ColorPalette.accent : ColorPalette.textSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                selected ? Color.white.opacity(0.08) : Color.clear,
                in: Capsule()
            )
        }
        .buttonStyle(.plain)
    }
}

typealias TabBarView = MainTabView
