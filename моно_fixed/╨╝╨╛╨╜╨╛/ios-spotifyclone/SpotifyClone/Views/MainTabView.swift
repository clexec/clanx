//
//  MainTabView.swift
//  SpotifyClone
//
//  Root navigation shell: Home / Search / Library / Liked tabs with a custom
//  liquid-glass tab bar inspired by iOS 26 pill-style design.
//

import SwiftUI

enum AppTab: Int, CaseIterable, Identifiable {
    case home, liked, library, search
    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home:    return "Главная"
        case .liked:   return "Избранное"
        case .library: return "Профиль"
        case .search:  return "Поиск"
        }
    }

    var icon: String {
        switch self {
        case .home:    return "house.fill"
        case .liked:   return "heart.fill"
        case .library: return "person.fill"
        case .search:  return "magnifyingglass"
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home
    @State private var showPlayer = false
    private let player = AudioPlayer.shared

    var body: some View {
        ZStack(alignment: .bottom) {
            Theme.background.ignoresSafeArea()

            // Active tab content
            Group {
                switch selectedTab {
                case .home:    HomeView()
                case .liked:   LibraryView()
                case .library: SettingsView()
                case .search:  SearchView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Floating mini-player + tab bar stack
            VStack(spacing: 6) {
                if player.currentTrack != nil {
                    MiniPlayerView { showPlayer = true }
                        .padding(.horizontal, 10)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                LiquidGlassTabBar(selectedTab: $selectedTab)
            }
            .padding(.bottom, 6)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: player.currentTrack?.id)
        .fullScreenCover(isPresented: $showPlayer) {
            PlayerView()
        }
    }
}

// MARK: - Custom Liquid Glass Tab Bar

struct LiquidGlassTabBar: View {
    @Binding var selectedTab: AppTab
    @Namespace private var namespace

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                tabButton(tab)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 7)
        .background {
            if #available(iOS 26.0, *) {
                // Настоящий Liquid Glass — без clipShape, он сам обрезает по форме
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.clear)
                    .glassEffect(
                        .regular.tint(Color.black.opacity(0.05)),
                        in: .rect(cornerRadius: 28)
                    )
            } else {
                // Fallback для iOS < 26
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [.white.opacity(0.25), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            }
        }
        .shadow(color: .black.opacity(0.35), radius: 18, y: 6)
        .padding(.horizontal, 24)
    }

    private func tabButton(_ tab: AppTab) -> some View {
        let isSelected = selectedTab == tab

        return Button {
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.impactOccurred()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 3) {
                ZStack {
                    // Выделенная таблетка под иконкой активного таба
                    if isSelected {
                        Capsule()
                            .fill(Color.white.opacity(0.18))
                            .frame(width: 46, height: 30)
                            .matchedGeometryEffect(id: "tabPill", in: namespace)
                    }

                    Image(systemName: tab.icon)
                        .font(.system(size: 17, weight: isSelected ? .bold : .regular))
                        .symbolEffect(.bounce, value: isSelected)
                        .foregroundStyle(isSelected ? .white : Color(white: 0.55))
                        .frame(width: 46, height: 30)
                }

                Text(tab.title)
                    .font(.system(size: 9.5, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .white : Color(white: 0.5))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 3)
        }
        .buttonStyle(.plain)
    }
}
