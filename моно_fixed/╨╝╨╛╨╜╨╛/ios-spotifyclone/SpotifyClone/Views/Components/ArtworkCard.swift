import SwiftUI

struct Artwork: View {
    let url: String?
    let seed: String
    var cornerRadius: CGFloat = Theme.cardCornerRadius
    var circular: Bool = false

    private var shape: AnyShape {
        circular ? AnyShape(Circle()) : AnyShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    var body: some View {
        placeholder
            .overlay {
                if let url, let parsed = URL(string: url) {
                    AsyncImage(url: parsed) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fill).allowsHitTesting(false)
                        } else {
                            Color.clear
                        }
                    }
                }
            }
            .clipShape(shape)
    }

    private var placeholder: some View {
        let base = Color.seeded(seed)
        return shape
            .fill(
                LinearGradient(
                    colors: [base.opacity(0.9), base.opacity(0.45)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                Image(systemName: "music.note")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
            }
    }
}
