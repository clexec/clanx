//
//  MainTabView.swift
//  SpotifyClone
//
//  Root navigation shell: Home / Search / Library tabs with a custom
//  liquid-glass tab bar, a floating mini-player and the full-screen player.
//

import SwiftUI

enum AppTab: Int, CaseIterable, Identifiable {
    case home, search, library
    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .search: return "Search"
        case .library: return "Your Library"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .search: return "magnifyingglass"
        case .library: return "books.vertical.fill"
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

            // Active tab content.
            Group {
                switch selectedTab {
                case .home: HomeView()
                case .search: SearchView()
                case .library: LibraryView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Floating mini-player + tab bar stack.
            VStack(spacing: 8) {
                if player.currentTrack != nil {
                    MiniPlayerView { showPlayer = true }
                        .padding(.horizontal, 10)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                LiquidGlassTabBar(selectedTab: $selectedTab)
            }
            .padding(.bottom, 4)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: player.currentTrack?.id)
        .fullScreenCover(isPresented: $showPlayer) {
            PlayerView()
        }
    }
}

/// Custom tab bar rendered on a liquid-glass surface.
struct LiquidGlassTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                tabButton(tab)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background(LiquidGlassBackground(cornerRadius: 30, tint: Theme.accent))
        .clipShape(.rect(cornerRadius: 30))
        .shadow(color: .black.opacity(0.4), radius: 16, y: 6)
        .padding(.horizontal, 28)
    }

    private func tabButton(_ tab: AppTab) -> some View {
        let isSelected = selectedTab == tab
        return Button {
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.impactOccurred()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .symbolEffect(.bounce, value: isSelected)
                Text(tab.title)
                    .font(.system(size: 10, weight: .semibold))
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? Theme.accentBright : Theme.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background {
                if isSelected {
                    Capsule()
                        .fill(Theme.accent.opacity(0.16))
                        .matchedGeometryEffect(id: "tabHighlight", in: namespace)
                }
            }
        }
        .buttonStyle(.plain)
    }

    @Namespace private var namespace
}
