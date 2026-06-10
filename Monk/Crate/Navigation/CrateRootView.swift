import SwiftUI

struct CrateRootView: View {
    @EnvironmentObject private var player: PlayerManager
    @State private var tab = 0
    @State private var showPlayer = false
    @State private var showSearch = false

    var body: some View {
        ZStack(alignment: .bottom) {
            CrateColor.background.ignoresSafeArea()
            screen
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: player.currentTrack != nil ? 130 : 80)
                }
            VStack(spacing: 10) {
                if player.currentTrack != nil {
                    MiniPlayerBar()
                        .onTapGesture { showPlayer = true }
                }
                CrateTabBar(selection: $tab) { showSearch = true }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .sheet(isPresented: $showPlayer) { PlayerScreen() }
        .sheet(isPresented: $showSearch) { SearchSheetView() }
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
