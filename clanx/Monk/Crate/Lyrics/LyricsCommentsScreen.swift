import SwiftUI

struct LyricsCommentsScreen: View {
    let track: Track
    @EnvironmentObject private var persistence: PersistenceController
    @EnvironmentObject private var auth: AuthenticationManager
    @EnvironmentObject private var player: PlayerManager
    @Environment(\.dismiss) private var dismiss
    @State private var draft = ""
    @State private var lyrics: String? = nil
    @State private var lyricsLoading = false
    @State private var selectedTab = 0

    private var comments: [Comment] {
        persistence.comments
            .filter { $0.trackID == track.id }
            .sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            LinearGradient(
                colors: [Color(red:0.08,green:0.05,blue:0.18), Color.black],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                ZStack {
                    VStack(spacing: 4) {
                        Text(track.title)
                            .font(.custom("DelaGothicOne-Regular", size: 16))
                            .foregroundStyle(.white).lineLimit(1)
                        Text(track.artistName)
                            .font(.caption).foregroundStyle(CrateColor.secondaryText)
                    }
                    HStack {
                        Button("Готово") { dismiss() }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .glassEffect(.regular.interactive(), in: Capsule())
                        Spacer()
                    }
                }
                .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 12)

                // Tab switcher — glass chips
                HStack(spacing: 10) {
                    tabChip("Текст", index: 0)
                    tabChip("Комментарии \(comments.isEmpty ? "" : "· \(comments.count)")", index: 1)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

                Divider().background(Color.white.opacity(0.08))

                // Content
                if selectedTab == 0 {
                    lyricsView
                } else {
                    commentsView
                }
            }
        }
        .task { await loadLyrics() }
    }

    // MARK: - Tab chip

    private func tabChip(_ title: String, index: Int) -> some View {
        Button { withAnimation(.spring(response: 0.25)) { selectedTab = index } } label: {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(selectedTab == index ? .black : .white)
                .padding(.horizontal, 16).padding(.vertical, 8)
                .background(selectedTab == index ? Color.white : Color.clear, in: Capsule())
                .glassEffect(.regular, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Lyrics

    private var lyricsView: some View {
        Group {
            if lyricsLoading {
                VStack { Spacer(); ProgressView().tint(.white); Spacer() }
            } else if let text = lyrics {
                ScrollView(showsIndicators: false) {
                    Text(text)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(.white)
                        .lineSpacing(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                }
            } else {
                VStack(spacing: 14) {
                    Spacer()
                    Image(systemName: "text.quote")
                        .font(.system(size: 44)).foregroundStyle(CrateColor.secondaryText)
                    Text("Текст не найден")
                        .font(.headline).foregroundStyle(CrateColor.secondaryText)
                    Text("Попробуйте другой трек")
                        .font(.subheadline).foregroundStyle(CrateColor.secondaryText.opacity(0.6))
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Comments

    private var commentsView: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                if comments.isEmpty {
                    VStack(spacing: 16) {
                        Spacer().frame(height: 50)
                        Image(systemName: "bubble.left")
                            .font(.system(size: 44)).foregroundStyle(CrateColor.secondaryText)
                        Text("Нет комментариев")
                            .font(.headline).foregroundStyle(CrateColor.secondaryText)
                        Text("Будьте первым!")
                            .font(.subheadline).foregroundStyle(CrateColor.secondaryText.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(comments) { comment in
                            CommentRow(comment: comment) { replyText in
                                postComment(text: "↳ \(replyText)", prefix: "")
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                if comment.userID == (auth.currentUser?.id ?? "guest") {
                                    Button(role: .destructive) {
                                        persistence.deleteComment(comment)
                                    } label: {
                                        Label("Удалить", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20).padding(.vertical, 16)
                }
            }

            CommentComposer(text: $draft, onSend: { postComment(text: draft, prefix: "") })
        }
    }

    // MARK: - Helpers

    private func postComment(text: String, prefix: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let user = auth.currentUser
        persistence.saveComment(Comment(
            id: UUID().uuidString,
            trackID: track.id,
            userID: user?.id ?? "guest",
            displayName: user?.displayName ?? "Гость",
            text: trimmed,
            createdAt: Date()
        ))
        if text == draft { draft = "" }
    }

    private func loadLyrics() async {
        guard lyrics == nil else { return }
        lyricsLoading = true
        lyrics = await LyricsService.fetch(title: track.title, artist: track.artistName)
        lyricsLoading = false
    }
}
