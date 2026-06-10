import SwiftUI

struct CommentRow: View {
    let comment: Comment
    let onReply: (String) -> Void

    @State private var isLiked = false
    @State private var isDisliked = false
    @State private var likeCount: Int
    @State private var showReply = false
    @State private var replyText = ""

    init(comment: Comment, onReply: @escaping (String) -> Void = { _ in }) {
        self.comment = comment
        self.onReply = onReply
        self._likeCount = State(initialValue: comment.likeCount)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable().frame(width: 38, height: 38)
                    .foregroundStyle(CrateColor.surfaceElevated)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(comment.displayName)
                            .font(.subheadline.bold()).foregroundStyle(.white)
                        Text(CrateFormat.relativeString(comment.createdAt))
                            .font(.caption2).foregroundStyle(CrateColor.secondaryText)
                    }
                    Text(comment.text)
                        .font(.subheadline).foregroundStyle(CrateColor.primaryText)

                    HStack(spacing: 18) {
                        // Like
                        Button {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.55)) {
                                isLiked.toggle()
                                if isLiked { isDisliked = false; likeCount += 1 }
                                else { likeCount -= 1 }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                                    .foregroundStyle(isLiked ? .white : CrateColor.secondaryText)
                                    .scaleEffect(isLiked ? 1.2 : 1.0)
                                if likeCount > 0 {
                                    Text("\(likeCount)").font(.caption2).foregroundStyle(CrateColor.secondaryText)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .animation(.spring(response: 0.28, dampingFraction: 0.55), value: isLiked)

                        // Dislike
                        Button {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.55)) {
                                isDisliked.toggle()
                                if isDisliked { isLiked = false }
                            }
                        } label: {
                            Image(systemName: isDisliked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                                .foregroundStyle(isDisliked ? .white : CrateColor.secondaryText)
                                .scaleEffect(isDisliked ? 1.2 : 1.0)
                        }
                        .buttonStyle(.plain)
                        .animation(.spring(response: 0.28, dampingFraction: 0.55), value: isDisliked)

                        // Reply
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                showReply.toggle()
                            }
                        } label: {
                            Label(bi("Ответить", "Reply"), systemImage: "arrowshape.turn.up.left")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(showReply ? .white : CrateColor.secondaryText)
                        }
                        .buttonStyle(.plain)
                    }
                    .font(.caption.weight(.medium))
                    .padding(.top, 4)
                }
                Spacer(minLength: 0)
            }

            if showReply {
                HStack(spacing: 10) {
                    TextField(bi("Ответ…", "Reply…"), text: $replyText)
                        .textFieldStyle(.plain)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .glassEffect(.regular, in: Capsule())
                        .onSubmit { sendReply() }

                    Button(action: sendReply) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 38, height: 38)
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .glassEffect(.regular, in: Circle())
                    .disabled(replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.leading, 50)
                .padding(.top, 10)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private func sendReply() {
        let text = replyText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        onReply(text)
        replyText = ""
        withAnimation { showReply = false }
    }
}
