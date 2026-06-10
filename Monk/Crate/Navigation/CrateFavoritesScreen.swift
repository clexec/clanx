import SwiftUI

struct CrateFavoritesScreen: View {
    @EnvironmentObject private var player: PlayerManager
    @EnvironmentObject private var library: LibraryManager

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Text(bi("Избранное", "Favorites")).font(.title2.bold()).foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                if library.likedTracks.isEmpty {
                    Text(bi("Пока пусто", "Nothing here yet"))
                        .font(.subheadline).foregroundStyle(CrateColor.secondaryText)
                        .frame(maxWidth: .infinity).padding(.top, 60)
                } else {
                    ForEach(library.likedTracks) { track in
                        PlaylistTile(track: track)
                            .onTapGesture { player.play(track, queue: library.likedTracks) }
                    }
                }
            }
            .padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 170)
        }
        .background(CrateColor.background)
    }
}
