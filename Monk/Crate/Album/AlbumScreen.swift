import SwiftUI

struct AlbumScreen: View {
    let album: Album
    @EnvironmentObject private var player: PlayerManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .top) {
            backdrop
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    header
                    CoverArtView(url: album.artworkURL).frame(width: 230, height: 230).padding(.top, 8)
                    Text(album.title).font(.largeTitle.bold()).foregroundStyle(.white)
                        .multilineTextAlignment(.center).padding(.top, 20).padding(.horizontal, 24)
                    actions.padding(.top, 20)
                    trackList.padding(.top, 28)
                }
                .padding(.horizontal, 20).padding(.bottom, 40)
            }
        }
        .background(CrateColor.background.ignoresSafeArea())
    }

    private var backdrop: some View {
        AsyncImage(url: album.artworkURL) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            CrateColor.surface
        }
        .frame(height: 360).frame(maxWidth: .infinity).clipped()
        .blur(radius: 60).opacity(0.55)
        .overlay(LinearGradient(colors: [.clear, CrateColor.background], startPoint: .top, endPoint: .bottom))
        .ignoresSafeArea()
    }

    private var header: some View {
        ZStack {
            Text(album.artistName).font(.subheadline.weight(.semibold)).foregroundStyle(.white).lineLimit(1)
            HStack {
                Spacer()
                Button(bi("Готово", "Done")) { dismiss() }
                    .font(.subheadline.weight(.medium)).foregroundStyle(.white)
                    .padding(.horizontal, 16).padding(.vertical, 8).crateGlass(Capsule())
            }
        }
        .padding(.top, 8)
    }

    private var actions: some View {
        HStack(spacing: 14) {
            Button { play(shuffled: false) } label: {
                Label(bi("Слушать", "Play"), systemImage: "play.fill")
                    .font(.headline).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .contentShape(Capsule())
            }
            .buttonStyle(.plain)
            .crateGlass(Capsule())
            Button { play(shuffled: true) } label: {
                Label(bi("Перемешать", "Shuffle"), systemImage: "shuffle")
                    .font(.headline).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .crateGlass(Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    private var trackList: some View {
        VStack(spacing: 0) {
            HStack {
                Text(bi("Треки", "Tracks")).font(.title3.bold()).foregroundStyle(.white)
                Spacer()
            }
            .padding(.bottom, 8)
            ForEach(Array(album.tracks.enumerated()), id: \.element.id) { index, track in
                AlbumTrackRow(index: index + 1, track: track)
                    .contentShape(Rectangle())
                    .onTapGesture { player.play(track, queue: album.tracks) }
            }
        }
    }

    private func play(shuffled: Bool) {
        let queue = shuffled ? album.tracks.shuffled() : album.tracks
        guard let first = queue.first else { return }
        player.play(first, queue: Array(queue.dropFirst()))
    }
}
