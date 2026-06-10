import SwiftUI

struct SearchField: View {
    @Binding var text: String
    let onSubmit: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass").font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white).frame(width: 30, height: 30).background(Color.blue, in: Circle())
            TextField(bi("Поиск", "Search"), text: $text)
                .textFieldStyle(.plain).foregroundStyle(.white)
                .submitLabel(.search).onSubmit(onSubmit)
        }
        .padding(8).padding(.trailing, 8).crateGlass(Capsule())
    }
}

struct FilterChips: View {
    let selection: Int
    let titles: [String]
    let onSelect: (Int) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(titles.indices, id: \.self) { index in
                    chip(index)
                }
            }
        }
    }

    @ViewBuilder
    private func chip(_ index: Int) -> some View {
        let label = Text(titles[index]).font(.subheadline.weight(.semibold))
            .padding(.horizontal, 18).padding(.vertical, 10)
        if selection == index {
            label.foregroundStyle(.black).background(.white, in: Capsule())
                .onTapGesture { onSelect(index) }
        } else {
            label.foregroundStyle(.white).crateGlass(Capsule())
                .onTapGesture { onSelect(index) }
        }
    }
}

struct PlaylistTile: View {
    let track: Track

    var body: some View {
        HStack(spacing: 12) {
            CoverArtView(url: track.artworkURL, corner: 8).frame(width: 48, height: 48)
            VStack(alignment: .leading, spacing: 2) {
                Text(track.title).font(.subheadline.bold()).foregroundStyle(.white).lineLimit(1)
                Text(track.artistName).font(.caption).foregroundStyle(CrateColor.secondaryText).lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(8).frame(maxWidth: .infinity, alignment: .leading)
        .crateGlass(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct RecommendedCarousel: View {
    let tracks: [Track]
    let onTap: (Track) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(tracks) { track in
                    CoverArtView(url: track.artworkURL, corner: 14)
                        .frame(width: 150, height: 150)
                        .onTapGesture { onTap(track) }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}
