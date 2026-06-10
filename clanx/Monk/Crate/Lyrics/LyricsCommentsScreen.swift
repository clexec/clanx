import SwiftUI

struct LyricsCommentsScreen: View {
    let track: Track
    @EnvironmentObject private var persistence: PersistenceController
    @EnvironmentObject private var auth: AuthenticationManager
    @EnvironmentObject private var player: PlayerManager
    @Environment(\.dismiss) private var dismiss
    @State private var draft = ""

    private var comments: [Comment] {
        persistence.comments
            .filter { $0.trackID == track.id }
            .sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        ZStack {
            CrateColor.background.ignoresSafeArea()
            VStack(spacing: 0) {
                header.padding(.bottom, 8)

                // Native TabView for Lyrics / Comments
                TabView {
                    Tab(bi("Текст", "Lyrics"), systemImage: "text.quote") {
                        lyricsTab
                    }
                    Tab(bi("Комментарии", "Comments"), systemImage: "bubble.left") {
                        commentsTab
                    }
                }
            }
        }
    }

    private var header: some View {
        ZStack {
            VStack(spacing: 4) {
                Text(track.title).font(.headline).foregroundStyle(.white).lineLimit(1)
                Text(track.artistName).font(.caption).foregroundStyle(CrateColor.secondaryText).lineLimit(1)
            }
            HStack {
                Button(bi("Готово", "Done")) { dismiss() }
                    .font(.subheadline.weight(.medium)).foregroundStyle(.white)
                    .padding(.horizontal, 16).padding(.vertical, 8).crateGlass(Capsule())
                Spacer()
            }
        }
        .padding(.horizontal, 20).padding(.top, 16)
    }

    private var lyricsTab: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "text.quote")
                .font(.system(size: 40)).foregroundStyle(CrateColor.secondaryText)
            Text(bi("Текст пока недоступен", "Lyrics not available yet"))
                .font(.subheadline).foregroundStyle(CrateColor.secondaryText)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CrateColor.background)
    }

    private var commentsTab: some View {
        VStack(spacing: 0) {
            if comments.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "bubble.left")
                        .font(.system(size: 40)).foregroundStyle(CrateColor.secondaryText)
                    Text(bi("Пока нет комментариев", "No comments yet"))
                        .font(.subheadline).foregroundStyle(CrateColor.secondaryText)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        ForEach(comments) { comment in
                            CommentRow(comment: comment) { replyText in
                                let user = auth.currentUser
                                let reply = Comment(
                                    id: UUID().uuidString,
                                    trackID: track.id,
                                    userID: user?.id ?? "guest",
                                    displayName: "↳ " + (user?.displayName ?? bi("Гость", "Guest")),
                                    text: replyText,
                                    createdAt: Date()
                                )
                                persistence.saveComment(reply)
                            }
                        }
                    }
                    .padding(20)
                }
            }
            CommentComposer(text: $draft, onSend: send)
        }
        .background(CrateColor.background)
    }

    private func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        let user = auth.currentUser
        let comment = Comment(
            id: UUID().uuidString,
            trackID: track.id,
            userID: user?.id ?? "guest",
            displayName: user?.displayName ?? bi("Гость", "Guest"),
            text: text,
            createdAt: Date()
        )
        persistence.saveComment(comment)
        draft = ""
    }
}
