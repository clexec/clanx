//
//  SettingsView.swift
//  SpotifyClone
//
//  Settings sheet: connect a Yandex Music token (with instructions) and
//  toggle the data source. When no token is set, the demo catalog is used.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    private let store = LibraryStore.shared

    @State private var tokenInput: String = LibraryStore.shared.token
    @State private var showSaved = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    statusCard
                    tokenCard
                    instructionsCard
                    Color.clear.frame(height: 40)
                }
                .padding(16)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Theme.accent)
                }
            }
        }
    }

    private var statusCard: some View {
        HStack(spacing: 12) {
            Image(systemName: store.source == .yandex ? "checkmark.seal.fill" : "music.note.house")
                .font(.system(size: 28))
                .foregroundStyle(store.source == .yandex ? Theme.accent : Theme.textSecondary)
            VStack(alignment: .leading, spacing: 4) {
                Text(store.source == .yandex ? "Connected to Yandex Music" : "Demo Mode")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                Text(store.source == .yandex
                     ? "Real tracks, artists and search are active."
                     : "Using a built-in demo catalog. Add a token for real music.")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .glassCard(cornerRadius: 16, tint: Theme.accent)
    }

    private var tokenCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Yandex Music Token")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)

            SecureField("Paste your OAuth token", text: $tokenInput)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(12)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .foregroundStyle(Theme.textPrimary)

            HStack(spacing: 12) {
                Button {
                    store.token = tokenInput.trimmingCharacters(in: .whitespacesAndNewlines)
                    showSaved = true
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { showSaved = false }
                } label: {
                    Text(showSaved ? "Saved!" : "Save & Connect")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Theme.accent)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                if !store.token.isEmpty {
                    Button {
                        store.token = ""
                        tokenInput = ""
                    } label: {
                        Text("Disconnect")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Theme.textPrimary)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .overlay(Capsule().strokeBorder(Theme.textSecondary, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 16)
    }

    private var instructionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("How to get a token", systemImage: "info.circle")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)

            ForEach(Array(steps.enumerated()), id: \.offset) { idx, step in
                HStack(alignment: .top, spacing: 10) {
                    Text("\(idx + 1)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(width: 22, height: 22)
                        .background(Theme.accent)
                        .clipShape(Circle())
                    Text(step)
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Text("Tip: a popular way is to use the open-source “Yandex Music token” extractor tools. Keep your token private — it grants access to your account.")
                .font(.system(size: 12))
                .foregroundStyle(Theme.textTertiary)
                .padding(.top, 4)
        }
        .padding(16)
        .glassCard(cornerRadius: 16)
    }

    private let steps: [String] = [
        "Open music.yandex.ru in a browser and sign in to your account.",
        "Use a trusted OAuth helper to request a Yandex Music token (the API uses an OAuth token, not your password).",
        "Copy the token string it gives you.",
        "Paste it into the field above and tap Save & Connect."
    ]
}
