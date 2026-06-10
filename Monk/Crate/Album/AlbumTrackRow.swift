import SwiftUI

struct AlbumTrackRow: View {
    let index: Int
    let track: Track

    var body: some View {
        HStack(spacing: 14) {
            Text("\(index)")
                .font(.subheadline).foregroundStyle(CrateColor.secondaryText)
                .frame(width: 22, alignment: .center)
            Text(track.title).font(.subheadline).foregroundStyle(.white).lineLimit(1)
            Spacer()
            Text(track.durationText).font(.caption).foregroundStyle(CrateColor.secondaryText)
        }
        .padding(.vertical, 12)
    }
}
