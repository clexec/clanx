import SwiftUI

struct CrateFavoritesScreen: View {
    @EnvironmentObject private var player: PlayerManager
    @EnvironmentObject private var library: LibraryManager

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Text(bi("Избранное", "Favorites"))
                    .font(.title2.bold()).foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .center)

                if library.likedTracks.isEmpty {
                    VStack(spacing: 16) {
                        Spacer().frame(height: 40)
                        Image(systemName: "heart.slash")
                            .font(.system(size: 40))
                            .foregroundStyle(CrateColor.secondaryText)
                        Text(bi("Пока пусто", "Nothing here yet"))
                            .font(.subheadline).foregroundStyle(CrateColor.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    VStack(spacing: 1) {
                        ForEach(Array(library.likedTracks.enumerated()), id: \.element.id) { index, track in
                            HStack(spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.caption).foregroundStyle(CrateColor.secondaryText)
                                    .frame(width: 20, alignment: .center)
                                CoverArtView(url: track.artworkURL, corner: 8)
                                    .frame(width: 44, height: 44)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(track.title).font(.subheadline.bold()).foregroundStyle(.white).lineLimit(1)
                                    Text(track.artistName).font(.caption).foregroundStyle(CrateColor.secondaryText).lineLimit(1)
                                }
                                Spacer()
                                Text(track.durationText).font(.caption2).foregroundStyle(CrateColor.secondaryText)
                            }
                            .padding(.horizontal, 14).padding(.vertical, 10)
                            .contentShape(Rectangle())
                            .onTapGesture { player.play(track, queue: library.likedTracks) }
                        }
                    }
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
            }
            .padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 170)
        }
        .background(CrateColor.background)
    }
}
