import SwiftUI

struct ProfileView: View {
    @State private var token = ""
    @State private var tokenSaved = false
    private let store = LibraryStore.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        avatarSection
                        statsSection
                        tokenSection
                        Spacer(minLength: 60)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.large)
            .onAppear { token = store.token }
        }
    }

    private var avatarSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay(Circle().fill(Color.black.opacity(0.4)))
                    .frame(width: 90, height: 90)
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Theme.textSecondary)
            }
            Text("@clexec")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Theme.textPrimary)
        }
        .padding(.top, 8)
    }

    private var statsSection: some View {
        HStack(spacing: 12) {
            statCard(value: "\(store.likedTracks.count)", label: "Треков")
            statCard(value: "\(store.savedAlbums.count)", label: "Альбомов")
            statCard(value: "\(store.userTracks.count)", label: "Добавлено")
        }
    }

    private func statCard(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Theme.accent)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 16).fill(Color.black.opacity(0.4)))
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
        )
    }

    private var tokenSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Яндекс Музыка", systemImage: "key.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.textSecondary)

            HStack(spacing: 10) {
                SecureField("", text: $token,
                    prompt: Text("Вставить токен").foregroundColor(Theme.textTertiary))
                    .foregroundStyle(Theme.textPrimary)
                    .font(.system(size: 14))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                Button {
                    store.token = token
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    withAnimation { tokenSaved = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation { tokenSaved = false }
                    }
                } label: {
                    Image(systemName: tokenSaved ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(tokenSaved ? Theme.accent : Theme.textSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: 14).fill(Color.black.opacity(0.45)))
                    .overlay(RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
            )

            Text("Токен нужен для воспроизведения реальных треков из Яндекс Музыки.")
                .font(.system(size: 12))
                .foregroundStyle(Theme.textTertiary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 20).fill(Color.black.opacity(0.35)))
                .overlay(RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(Color.white.opacity(0.07), lineWidth: 1))
        )
    }
}
