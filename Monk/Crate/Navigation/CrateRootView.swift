import SwiftUI

struct CrateRootView: View {
    @EnvironmentObject private var player: PlayerManager
    @State private var tab = 0
    @State private var showPlayer = false

    var body: some View {
        ZStack(alignment: .bottom) {
            CrateColor.background.ignoresSafeArea()
            screen
            VStack(spacing: 10) {
                if player.currentTrack != nil {
                    MiniPlayerBar().onTapGesture { showPlayer = true }
                }
                CrateTabBar(selection: $tab) { tab = 0 }
            }
            .padding(.horizontal, 16).padding(.bottom, 8)
        }
        .sheet(isPresented: $showPlayer) { PlayerScreen() }
    }

    @ViewBuilder
    private var screen: some View {
        switch tab {
        case 1: CrateFavoritesScreen()
        case 2: CrateProfileScreen()
        default: HomeScreen()
        }
    }
}
