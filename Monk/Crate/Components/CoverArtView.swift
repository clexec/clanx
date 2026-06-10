import SwiftUI

struct CoverArtView: View {
    let url: URL?
    var corner: CGFloat = 24

    var body: some View {
        AsyncImage(url: url, transaction: Transaction(animation: .easeIn(duration: 0.18))) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            case .failure:
                placeholder
            default:
                placeholder.overlay(
                    ProgressView().tint(.white).scaleEffect(0.7)
                )
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        .shadow(color: .black.opacity(0.45), radius: 24, y: 14)
    }

    private var placeholder: some View {
        ZStack {
            CrateColor.surface
            Image(systemName: "music.note")
                .font(.system(size: 28, weight: .regular))
                .foregroundStyle(CrateColor.secondaryText)
        }
    }
}
