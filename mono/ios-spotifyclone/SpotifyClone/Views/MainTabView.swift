import SwiftUI

enum AppTab: Int, CaseIterable, Identifiable {
    case home, favorites, create, profile, search
    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home:      return "Главная"
        case .favorites: return "Избранное"
        case .create:    return "Создать"
        case .profile:   return "Профиль"
        case .search:    return ""
        }
    }

    var icon: String {
        switch self {
        case .home:      return "house.fill"
        case .favorites: return "heart.fill"
        case .create:    return "plus"
        case .profile:   return "person.fill"
        case .search:    return "magnifyingglass"
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home
    @State private var showPlayer = false
    @State private var showCreate = false
    private let player = AudioPlayer.shared

    var body: some View {
        ZStack(alignment: .bottom) {
            Theme.background.ignoresSafeArea()

            Group {
                switch selectedTab {
                case .home:      HomeView()
                case .favorites: LibraryView()
                case .create:    HomeView()
                case .profile:   ProfileView()
                case .search:    SearchView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(spacing: 8) {
                if player.currentTrack != nil {
                    MiniPlayerView { showPlayer = true }
                        .padding(.horizontal, 10)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                CustomTabBar(selectedTab: $selectedTab, onCreateTap: { showCreate = true })
            }
            .padding(.bottom, 4)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: player.currentTrack?.id)
        .fullScreenCover(isPresented: $showPlayer) { PlayerView() }
        .sheet(isPresented: $showCreate) { CreateTrackView() }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab
    let onCreateTap: () -> Void
    @Namespace private var ns

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                if tab == .create {
                    createButton
                } else if tab == .search {
                    searchButton
                } else {
                    regularTab(tab)
                }
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .fill(Color.black.opacity(0.55))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [.white.opacity(0.18), .white.opacity(0.04)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ), lineWidth: 1
                        )
                )
        )
        .shadow(color: .black.opacity(0.5), radius: 20, y: 8)
        .padding(.horizontal, 20)
    }

    private func regularTab(_ tab: AppTab) -> some View {
        let isSelected = selectedTab == tab
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedTab = tab }
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        } label: {
            VStack(spacing: 3) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: isSelected ? .bold : .regular))
                    .foregroundStyle(isSelected ? Theme.accent : .white.opacity(0.55))
                Text(tab.title)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(isSelected ? Theme.accent : .white.opacity(0.55))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background {
                if isSelected {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 52, height: 52)
                        .matchedGeometryEffect(id: "sel", in: ns)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var createButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            onCreateTap()
        } label: {
            VStack(spacing: 3) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Theme.accent, Theme.accent.opacity(0.7)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 38, height: 38)
                        .shadow(color: Theme.accent.opacity(0.5), radius: 8)
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.black)
                }
                Text("Создать")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.55))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 5)
        }
        .buttonStyle(.plain)
    }

    private var searchButton: some View {
        let isSelected = selectedTab == .search
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedTab = .search }
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        } label: {
            ZStack {
                Circle()
                    .fill(isSelected ? Color.white.opacity(0.12) : Color.clear)
                    .frame(width: 48, height: 48)
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(isSelected ? Theme.accent : .white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 5)
        }
        .buttonStyle(.plain)
    }
}
