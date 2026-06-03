import SwiftUI
import AVFoundation
import UniformTypeIdentifiers

struct CreateTrackView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var artist = ""
    @State private var album = ""
    @State private var genre = ""
    @State private var audioURL: URL?
    @State private var showFilePicker = false
    @State private var isSaving = false
    @State private var saved = false

    private let store = LibraryStore.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        filePickerSection
                        formSection
                        saveButton
                        Spacer(minLength: 60)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Добавить трек")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Отмена") { dismiss() }
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.audio, .mp3, UTType("public.mpeg-4-audio") ?? .audio],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                audioURL = url
                if title.isEmpty { title = url.deletingPathExtension().lastPathComponent }
            }
        }
    }

    private var filePickerSection: some View {
        Button { showFilePicker = true } label: {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Theme.surface)
                        .frame(width: 80, height: 80)
                    if audioURL != nil {
                        Image(systemName: "waveform.circle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(Theme.accent)
                    } else {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 36))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                Text(audioURL != nil ? audioURL!.lastPathComponent : "Выбрать аудиофайл")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(audioURL != nil ? Theme.accent : Theme.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 240)
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.black.opacity(0.4))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(
                                audioURL != nil ? Theme.accent.opacity(0.5) : Color.white.opacity(0.1),
                                lineWidth: 1.5
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var formSection: some View {
        VStack(spacing: 14) {
            glassField(icon: "music.note",       placeholder: "Название трека *", text: $title)
            glassField(icon: "person.fill",      placeholder: "Артист *",         text: $artist)
            glassField(icon: "square.stack.fill", placeholder: "Альбом",          text: $album)
            glassField(icon: "tag.fill",         placeholder: "Жанр",             text: $genre)
        }
    }

    private func glassField(icon: String, placeholder: String, text: Binding<String>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.accent)
                .frame(width: 24)
            TextField("", text: text, prompt: Text(placeholder).foregroundColor(Theme.textTertiary))
                .foregroundStyle(Theme.textPrimary)
                .font(.system(size: 15))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.black.opacity(0.45)))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
        )
    }

    private var saveButton: some View {
        Button {
            guard !title.isEmpty, !artist.isEmpty else { return }
            isSaving = true
            let track = Track(
                id: UUID().uuidString,
                title: title,
                artistName: artist,
                albumTitle: album.isEmpty ? artist : album,
                duration: loadDuration(from: audioURL),
                coverURL: nil,
                streamURL: audioURL
            )
            store.addUserTrack(track)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            withAnimation { saved = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { dismiss() }
        } label: {
            HStack(spacing: 10) {
                if saved {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .bold))
                } else if isSaving {
                    ProgressView().tint(.black)
                } else {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18, weight: .bold))
                    Text("Добавить трек")
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        (title.isEmpty || artist.isEmpty)
                        ? AnyShapeStyle(Color.white.opacity(0.1))
                        : AnyShapeStyle(LinearGradient(
                            colors: [Theme.accent, Theme.accentBright],
                            startPoint: .leading, endPoint: .trailing
                          ))
                    )
                    .shadow(color: Theme.accent.opacity(0.4), radius: 12, y: 4)
            )
            .foregroundStyle((title.isEmpty || artist.isEmpty) ? Theme.textTertiary : .black)
        }
        .buttonStyle(.plain)
        .disabled(title.isEmpty || artist.isEmpty)
    }

    private func loadDuration(from url: URL?) -> TimeInterval {
        guard let url else { return 0 }
        let asset = AVURLAsset(url: url)
        let duration = asset.duration
        return CMTimeGetSeconds(duration)
    }
}
