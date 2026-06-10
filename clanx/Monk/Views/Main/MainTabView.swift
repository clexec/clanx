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
        HStack(spacing: 12) {
            // Left glass capsule — 3 tabs joined
            HStack(spacing: 0) {
                ForEach(AppTab.allCases, id: \.rawValue) { tab in
                    tabItem(tab)
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 0.5))

            // Right glass circle — search, physically separated
            Button { showSearch = true } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 54, height: 54)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 0.5))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .shadow(color: .black.opacity(0.35), radius: 16, y: 4)
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
