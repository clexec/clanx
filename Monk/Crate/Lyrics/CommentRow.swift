import SwiftUI

struct CommentRow: View {
    let comment: Comment

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .resizable().frame(width: 40, height: 40)
                .foregroundStyle(CrateColor.surfaceElevated)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(comment.displayName).font(.subheadline.bold()).foregroundStyle(.white)
                    Text(CrateFormat.relativeString(comment.createdAt))
                        .font(.caption2).foregroundStyle(CrateColor.secondaryText)
                }
                Text(comment.text).font(.subheadline).foregroundStyle(CrateColor.primaryText)
                HStack(spacing: 20) {
                    Label(bi("Ответить", "Reply"), systemImage: "arrowshape.turn.up.left")
                    Image(systemName: "hand.thumbsup")
                    Image(systemName: "hand.thumbsdown")
                }
                .font(.caption.weight(.medium)).foregroundStyle(CrateColor.secondaryText).padding(.top, 2)
            }
            Spacer(minLength: 0)
        }
    }
}
