import SwiftUI

private enum FavTab: String, CaseIterable {
    case liked     = "Любимые треки"
    case playlists = "Плейлисты"
    case artists   = "Исполнители"
}

struct CrateFavoritesScreen: View {
    @EnvironmentObject private var player: PlayerManager
    @EnvironmentObject private var library: LibraryManager
    @State private var tab: FavTab = .liked
    @State private var showCreate = false
    @State private var showImport = false

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Header
                Text("Избранное")
                    .font(.custom("DelaGothicOne-Regular", size: 26))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 16).padding(.bottom, 14)

                // Tab chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(FavTab.allCases, id: \.rawValue) { t in
                            Button {
                                withAnimation(.spring(response: 0.26)) { tab = t }
                            } label: {
                                Text(t.rawValue)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(tab == t ? .black : .white)
                                    .padding(.horizontal, 16).padding(.vertical, 9)
                                    .background(tab == t ? Color.white : Color.clear, in: Capsule())
                                    .crateGlass(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 10)

                Divider().background(Color.white.opacity(0.07))

                // Content
                ScrollView(showsIndicators: false) {
                    Group {
                        switch tab {
                        case .liked:     likedContent
                        case .playlists: playlistsContent
                        case .artists:   artistsContent
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 160)
                }
            }
            .background(CrateColor.background)

            // Sticky bottom buttons
            stickyActions
        }
        .sheet(isPresented: $showCreate) { CreatePlaylistSheet().environmentObject(library) }
        .sheet(isPresented: $showImport)  { ImportMusicSheet() }
    }

    // MARK: - Liked

    private var likedContent: some View {
        VStack(spacing: 0) {
            if library.likedTracks.isEmpty {
                emptyState(icon: "heart.fill",
                           color: .pink,
                           title: "Пока нет треков",
                           subtitle: "Лайкайте треки в плеере")
            } else {
                // Play-all row
                HStack {
                    Text("\(library.likedTracks.count) треков")
                        .font(.system(size: 13))
                        .foregroundStyle(CrateColor.secondaryText)
                    Spacer()
                    Button {
                        player.play(library.likedTracks[0], queue: library.likedTracks)
                    } label: {
                        Label("Слушать всё", systemImage: "play.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .background(Color.white, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 14)

                VStack(spacing: 1) {
                    ForEach(Array(library.likedTracks.enumerated()), id: \.element.id) { idx, track in
                        HStack(spacing: 12) {
                            Text("\(idx + 1)")
                                .font(.caption2).foregroundStyle(CrateColor.secondaryText)
                                .frame(width: 18, alignment: .trailing)
                            CoverArtView(url: track.artworkURL, corner: 8)
                                .frame(width: 46, height: 46)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(track.title)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.white).lineLimit(1)
                                Text(track.artistName)
                                    .font(.caption).foregroundStyle(CrateColor.secondaryText).lineLimit(1)
                            }
                            Spacer()
                            Text(track.durationText)
                                .font(.caption2).foregroundStyle(CrateColor.secondaryText)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .contentShape(Rectangle())
                        .onTapGesture { player.play(track, queue: library.likedTracks) }

                        if idx < library.likedTracks.count - 1 {
                            Divider().background(Color.white.opacity(0.06)).padding(.leading, 76)
                        }
                    }
                }
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Playlists

    private var playlistsContent: some View {
        VStack(spacing: 12) {
            if library.playlists.isEmpty {
                emptyState(icon: "music.note.list",
                           color: .purple,
                           title: "Нет плейлистов",
                           subtitle: "Нажмите «Создать плейлист»")
            } else {
                VStack(spacing: 1) {
                    ForEach(library.playlists) { pl in
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(LinearGradient(
                                        colors: [CrateColor.glassBackground.stops.first?.color ?? .gray,
                                                 Color(red:0.15,green:0.12,blue:0.22)],
                                        startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 52, height: 52)
                                if let url = pl.artworkURL {
                                    CoverArtView(url: url, corner: 10).frame(width: 52, height: 52)
                                } else {
                                    Image(systemName: "music.note.list")
                                        .foregroundStyle(.white.opacity(0.8))
                                }
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(pl.title)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.white).lineLimit(1)
                                Text("\(pl.tracks.count) треков")
                                    .font(.caption).foregroundStyle(CrateColor.secondaryText)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12)).foregroundStyle(CrateColor.secondaryText)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 10)
                    }
                }
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Artists

    private var artistsContent: some View {
        VStack(spacing: 0) {
            let artists: [(name: String, url: URL?, count: Int)] = Dictionary(
                grouping: library.likedTracks, by: \.artistName
            ).map { (name: $0.key, url: $0.value.first?.artworkURL, count: $0.value.count) }
             .sorted { $0.count > $1.count }

            if artists.isEmpty {
                emptyState(icon: "person.2.fill",
                           color: .orange,
                           title: "Нет исполнителей",
                           subtitle: "Появятся после лайков")
            } else {
                VStack(spacing: 1) {
                    ForEach(artists, id: \.name) { a in
                        Button {
                            let tracks = library.likedTracks.filter { $0.artistName == a.name }
                            if let f = tracks.first { player.play(f, queue: tracks) }
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(LinearGradient(
                                            colors: [.orange.opacity(0.5), .pink.opacity(0.4)],
                                            startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 50, height: 50)
                                    if let url = a.url {
                                        CoverArtView(url: url, corner: 25)
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                    } else {
                                        Text(String(a.name.prefix(1)).uppercased())
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                }
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(a.name)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.white).lineLimit(1)
                                    Text("\(a.count) треков")
                                        .font(.caption).foregroundStyle(CrateColor.secondaryText)
                                }
                                Spacer()
                                Image(systemName: "play.fill")
                                    .font(.system(size: 12)).foregroundStyle(CrateColor.secondaryText)
                            }
                            .padding(.horizontal, 14).padding(.vertical, 10)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Empty state

    private func emptyState(icon: String, color: Color, title: String, subtitle: String) -> some View {
        VStack(spacing: 14) {
            Spacer().frame(height: 50)
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 88, height: 88)
                Image(systemName: icon)
                    .font(.system(size: 34))
                    .foregroundStyle(color.opacity(0.8))
            }
            .crateGlass(Circle())
            Text(title)
                .font(.custom("DelaGothicOne-Regular", size: 18))
                .foregroundStyle(.white)
            Text(subtitle)
                .font(.subheadline).foregroundStyle(CrateColor.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Sticky bottom

    private var stickyActions: some View {
        VStack(spacing: 0) {
            LinearGradient(colors: [.black.opacity(0), .black],
                           startPoint: .top, endPoint: .bottom)
                .frame(height: 32).allowsHitTesting(false)

            HStack(spacing: 10) {
                Button { showCreate = true } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus").font(.system(size: 13, weight: .bold))
                        Text("Создать плейлист").font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(Color.white, in: Capsule())
                }
                .buttonStyle(.plain)

                Button { showImport = true } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.down").font(.system(size: 13, weight: .semibold))
                        Text("Своя музыка").font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .crateGlass(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20).padding(.bottom, 20)
            .background(Color.black)
        }
    }
}

// MARK: - Create playlist sheet

struct CreatePlaylistSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var library: LibraryManager
    @State private var name = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(LinearGradient(colors: [.purple.opacity(0.5), .blue.opacity(0.35)],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 110, height: 110)
                        .crateGlass(RoundedRectangle(cornerRadius: 22))
                    Image(systemName: "music.note.list")
                        .font(.system(size: 44)).foregroundStyle(.white)
                }
                .padding(.top, 16)

                TextField("Название плейлиста", text: $name)
                    .font(.custom("DelaGothicOne-Regular", size: 20))
                    .foregroundStyle(.white).tint(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Button {
                    let t = name.trimmingCharacters(in: .whitespaces)
                    guard !t.isEmpty else { return }
                    library.playlists.append(
                        Playlist(id: UUID().uuidString, title: t, subtitle: "Mono",
                                 artworkURL: nil, tracks: [], createdAt: Date()))
                    dismiss()
                } label: {
                    Text("Создать")
                        .font(.system(size: 16, weight: .semibold)).foregroundStyle(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 15)
                        .background(name.isEmpty ? Color.gray.opacity(0.4) : Color.white, in: Capsule())
                }
                .buttonStyle(.plain).disabled(name.isEmpty)
                .padding(.horizontal, 24)
                .animation(.spring(response: 0.2), value: name.isEmpty)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(CrateColor.background.ignoresSafeArea())
            .navigationTitle("Новый плейлист")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Отмена") { dismiss() }.foregroundStyle(.white)
                }
            }
        }
    }
}

// MARK: - Import music sheet

struct ImportMusicSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.blue.opacity(0.4), .cyan.opacity(0.25)],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 110, height: 110)
                        .crateGlass(Circle())
                    Image(systemName: "music.note.house.fill")
                        .font(.system(size: 44)).foregroundStyle(.white)
                }
                .padding(.top, 16)

                Text("Добавить свою музыку")
                    .font(.custom("DelaGothicOne-Regular", size: 20))
                    .foregroundStyle(.white).multilineTextAlignment(.center)

                Text("Импортируйте MP3, M4A, FLAC из приложения «Файлы»")
                    .font(.subheadline).foregroundStyle(CrateColor.secondaryText)
                    .multilineTextAlignment(.center).padding(.horizontal, 24)

                VStack(spacing: 10) {
                    importRow(icon: "folder.fill",           color: .blue,  title: "Из Файлов")
                    importRow(icon: "icloud.and.arrow.down", color: .cyan,  title: "Из iCloud Drive")
                    importRow(icon: "wifi",                  color: .green, title: "По WiFi (скоро)")
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(CrateColor.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") { dismiss() }.font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                }
            }
        }
    }

    private func importRow(icon: String, color: Color, title: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.18))
                    .frame(width: 40, height: 40)
                Image(systemName: icon).foregroundStyle(color)
            }
            Text(title).font(.system(size: 15, weight: .medium)).foregroundStyle(.white)
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(CrateColor.secondaryText)
        }
        .padding(14)
        .crateGlass(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
