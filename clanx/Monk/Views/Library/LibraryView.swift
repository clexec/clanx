import SwiftUI

// MARK: - Tabs

private enum FavTab: String, CaseIterable {
    case liked     = "Любимые треки"
    case playlists = "Плейлисты"
    case artists   = "Исполнители"
}

// MARK: - Main View

struct LibraryView: View {
    @EnvironmentObject private var library: LibraryManager
    @EnvironmentObject private var player: PlayerManager
    @State private var selectedTab: FavTab = .liked
    @State private var showCreatePlaylist = false
    @State private var showImportMusic = false

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Title
                Text("Избранное")
                    .font(.delaTitle)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                    .padding(.bottom, 14)

                // Tab selector
                tabSelector
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)

                Divider().background(Color.white.opacity(0.07))

                // Content
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        switch selectedTab {
                        case .liked:     likedContent
                        case .playlists: playlistsContent
                        case .artists:   artistsContent
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 130)
                }
            }

            // Sticky bottom action buttons
            stickyBottom
        }
        .background(Color.black.ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(isPresented: $showCreatePlaylist) { CreatePlaylistSheet() }
        .sheet(isPresented: $showImportMusic)    { ImportMusicSheet() }
    }

    // MARK: - Tab selector

    private var tabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(FavTab.allCases, id: \.rawValue) { tab in
                    Button {
                        withAnimation(.spring(response: 0.28)) { selectedTab = tab }
                    } label: {
                        Text(tab.rawValue)
                            .font(.dela(12))
                            .foregroundStyle(selectedTab == tab ? .black : .white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                selectedTab == tab ? Color.white : Color(white: 0.15),
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Liked tracks

    private var likedContent: some View {
        VStack(spacing: 0) {
            if library.likedTracks.isEmpty {
                emptyState(
                    icon: "heart.fill",
                    gradient: [ColorPalette.accent.opacity(0.35), ColorPalette.secondary.opacity(0.2)],
                    iconColor: ColorPalette.accent,
                    title: "Пока нет треков",
                    subtitle: "Лайкайте треки в плеере\nи они появятся здесь"
                )
            } else {
                // Play all header
                HStack {
                    Text("\(library.likedTracks.count) треков")
                        .font(.delaCallout)
                        .foregroundStyle(ColorPalette.textSecondary)
                    Spacer()
                    Button {
                        player.play(library.likedTracks[0], queue: library.likedTracks)
                    } label: {
                        Label("Слушать всё", systemImage: "play.fill")
                            .font(.dela(12))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(ColorPalette.accent, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 14)

                ForEach(library.likedTracks) { track in
                    TrackRowView(track: track) {
                        player.play(track, queue: library.likedTracks)
                    }
                    Divider().background(Color.white.opacity(0.06)).padding(.leading, 66)
                }
            }
        }
    }

    // MARK: - Playlists

    private var playlistsContent: some View {
        VStack(spacing: 12) {
            if library.playlists.isEmpty {
                emptyState(
                    icon: "music.note.list",
                    gradient: [Color.purple.opacity(0.35), Color.blue.opacity(0.2)],
                    iconColor: .purple,
                    title: "Нет плейлистов",
                    subtitle: "Нажмите «Создать плейлист»\nчтобы начать коллекцию"
                )
            } else {
                ForEach(library.playlists) { playlist in
                    PlaylistRow(playlist: playlist)
                    Divider().background(Color.white.opacity(0.06)).padding(.leading, 74)
                }
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Artists

    private var artistsContent: some View {
        VStack(spacing: 0) {
            let artists = uniqueArtists
            if artists.isEmpty {
                emptyState(
                    icon: "person.2.fill",
                    gradient: [Color.orange.opacity(0.35), Color.pink.opacity(0.2)],
                    iconColor: .orange,
                    title: "Нет исполнителей",
                    subtitle: "Исполнители появятся здесь\nкогда вы лайкнете их треки"
                )
            } else {
                ForEach(artists, id: \.name) { a in
                    ArtistRow(name: a.name, artworkURL: a.artworkURL, count: a.count) {
                        let tracks = library.likedTracks.filter { $0.artistName == a.name }
                        if let f = tracks.first { player.play(f, queue: tracks) }
                    }
                    Divider().background(Color.white.opacity(0.06)).padding(.leading, 66)
                }
            }
        }
        .padding(.top, 8)
    }

    private var uniqueArtists: [(name: String, artworkURL: URL?, count: Int)] {
        Dictionary(grouping: library.likedTracks, by: \.artistName)
            .map { (name: $0.key, artworkURL: $0.value.first?.artworkURL, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    // MARK: - Empty state helper

    private func emptyState(icon: String, gradient: [Color], iconColor: Color, title: String, subtitle: String) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 90, height: 90)
                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundStyle(iconColor)
            }
            Text(title)
                .font(.delaTitle3)
                .foregroundStyle(.white)
            Text(subtitle)
                .font(.body)
                .foregroundStyle(ColorPalette.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    // MARK: - Sticky bottom buttons

    private var stickyBottom: some View {
        VStack(spacing: 0) {
            // Gradient fade
            LinearGradient(
                colors: [.black.opacity(0), .black],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 36)
            .allowsHitTesting(false)

            HStack(spacing: 10) {
                Button { showCreatePlaylist = true } label: {
                    HStack(spacing: 7) {
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .bold))
                        Text("Создать плейлист")
                            .font(.dela(12))
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(ColorPalette.accent, in: Capsule())
                }
                .buttonStyle(.plain)

                Button { showImportMusic = true } label: {
                    HStack(spacing: 7) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Своя музыка")
                            .font(.dela(12))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(white: 0.14), in: Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 0.5))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .background(Color.black)
        }
    }
}

// MARK: - Playlist row

private struct PlaylistRow: View {
    let playlist: Playlist
    var body: some View {
        HStack(spacing: 14) {
            RemoteArtworkView(url: playlist.artworkURL, size: 58)
            VStack(alignment: .leading, spacing: 4) {
                Text(playlist.title)
                    .font(.delaHeadline)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text("\(playlist.tracks.count) треков · \(playlist.subtitle)")
                    .font(.caption)
                    .foregroundStyle(ColorPalette.textSecondary)
                    .lineLimit(1)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13))
                .foregroundStyle(ColorPalette.textSecondary)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Artist row

private struct ArtistRow: View {
    let name: String
    let artworkURL: URL?
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Circle avatar
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [ColorPalette.accent.opacity(0.5), ColorPalette.secondary.opacity(0.4)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 52, height: 52)
                    if let url = artworkURL {
                        AsyncImage(url: url) { phase in
                            if case .success(let img) = phase {
                                img.resizable().scaledToFill()
                            }
                        }
                        .frame(width: 52, height: 52)
                        .clipShape(Circle())
                    } else {
                        Text(String(name.prefix(1)).uppercased())
                            .font(.delaTitle3)
                            .foregroundStyle(.white)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.delaHeadline)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text("\(count) \(count == 1 ? "трек" : count < 5 ? "трека" : "треков")")
                        .font(.caption)
                        .foregroundStyle(ColorPalette.textSecondary)
                }
                Spacer()
                Image(systemName: "play.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(ColorPalette.textSecondary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Create playlist sheet

struct _LegacyCreatePlaylistSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var library: LibraryManager
    @State private var name = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(colors: [ColorPalette.accent.opacity(0.4), ColorPalette.secondary.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 110, height: 110)
                    Image(systemName: "music.note.list")
                        .font(.system(size: 44))
                        .foregroundStyle(.white)
                }
                .padding(.top, 12)

                TextField("Название плейлиста", text: $name)
                    .font(.delaTitle3)
                    .foregroundStyle(.white)
                    .tint(ColorPalette.accent)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Button {
                    guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    library.playlists.append(
                        Playlist(id: UUID().uuidString, title: name, subtitle: "Mono",
                                 artworkURL: nil, tracks: [], createdAt: Date())
                    )
                    dismiss()
                } label: {
                    Text("Создать")
                        .font(.delaHeadline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(name.isEmpty ? Color.gray : ColorPalette.accent, in: Capsule())
                }
                .buttonStyle(.plain)
                .disabled(name.isEmpty)
                .padding(.horizontal, 24)
                .animation(.spring(response: 0.2), value: name.isEmpty)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(white: 0.07).ignoresSafeArea())
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

struct _LegacyImportMusicSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Color.blue.opacity(0.35), Color.cyan.opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 110, height: 110)
                    Image(systemName: "music.note.house.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.white)
                }
                .padding(.top, 12)

                Text("Добавить свою музыку")
                    .font(.delaTitle2)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text("Импортируйте MP3, M4A, FLAC и другие\nаудиофайлы из приложения «Файлы»")
                    .font(.body)
                    .foregroundStyle(ColorPalette.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                VStack(spacing: 12) {
                    importOption(icon: "folder.fill", color: .blue, title: "Из Файлов")
                    importOption(icon: "icloud.and.arrow.down", color: .cyan, title: "Из iCloud Drive")
                    importOption(icon: "wifi", color: .green, title: "По WiFi (скоро)")
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(white: 0.07).ignoresSafeArea())
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") { dismiss() }
                        .font(.delaBody)
                        .foregroundStyle(.white)
                }
            }
        }
    }

    private func importOption(icon: String, color: Color, title: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundStyle(color)
            }
            Text(title)
                .font(.delaBody)
                .foregroundStyle(.white)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13))
                .foregroundStyle(ColorPalette.textSecondary)
        }
        .padding(14)
        .background(Color(white: 0.12), in: RoundedRectangle(cornerRadius: 14))
    }
}

// Legacy typealiases
typealias PlaylistsView         = LibraryView
typealias LikedSongsView        = LibraryView
typealias SavedAlbumsView       = LibraryView
typealias FollowingArtistsView  = LibraryView
typealias LibraryFiltersView    = LibraryView
struct GenreCategoryCard: View {
    let title: String; let gradient: [Color]; let iconName: String
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing).frame(height: 90)
            Image(systemName: iconName).font(.system(size: 36)).foregroundStyle(.white.opacity(0.2)).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing).padding(8)
            Text(title).font(.delaBody).foregroundStyle(.white).padding(10)
        }.clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
