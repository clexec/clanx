import SwiftUI

struct CoverArtView: View {
    let url: URL?
    var corner: CGFloat = 24

    var body: some View {
        AsyncImage(url: url) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            ZStack {
                CrateColor.surface
                Image(systemName: "music.note")
                    .font(.system(size: 34, weight: .regular))
                    .foregroundStyle(CrateColor.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        .shadow(color: .black.opacity(0.45), radius: 24, y: 14)
    }
}
