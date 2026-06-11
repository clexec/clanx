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
            CrateColor.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    spotifyHeader
                    chipRow
                    Divider().background(Color.white.opacity(0.07))
                    tabContent
                        .padding(.horizontal, 16)
                        .padding(.bottom, 160)
                }
            }

            stickyActions
        }
        .sheet(isPresented: $showCreate) { CreatePlaylistSheet().environmentObject(library) }
        .sheet(isPresented: $showImport)  { ImportMusicSheet() }
    }

    // MARK: - Spotify-style header with cover mosaic

    private var spotifyHeader: some View {
        ZStack(alignment: .bottom) {
            // Mosaic background
            mosaicBackground
                .frame(height: 220)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [Color.black.opacity(0), Color.black.opacity(0.9)],
                        startPoint: .top, endPoint: .bottom
                    )
                )

            VStack(alignment: .leading, spacing: 4) {
                Text("Избранное")
                    .font(.custom("DelaGothicOne-Regular", size: 30))
                    .foregroundStyle(.white)
                Text("\(library.likedTracks.count) треков · \(library.playlists.count) плейлистов")
                    .font(.subheadline)
                    .foregroundStyle(CrateColor.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20).padding(.bottom, 18)
        }
    }

    @ViewBuilder
    private var mosaicBackground: some View {
        let covers = library.likedTracks.prefix(4).compactMap { $0.artworkURL }
        if covers.isEmpty {
            LinearGradient(
                colors: [Color(red:0.18,green:0.08,blue:0.38), Color(red:0.05,green:0.05,blue:0.18)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        } else {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2)], spacing: 2) {
                ForEach(0..<4, id: \.self) { i in
                    let url = i < covers.count ? covers[i] : covers[i % covers.count]
                    CoverArtView(url: url, corner: 0)
                        .aspectRatio(1, contentMode: .fill)
                        .clipped()
                }
            }
        }
    }

    // MARK: - Tab chips

    private var chipRow: some View {
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
                            .glassEffect(.regular, in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .animation(.spring(response: 0.25, dampingFraction: 0.7), value: tab == t)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 12)
    }

    // MARK: - Tab content

    @ViewBuilder
    private var tabContent: some View {
        switch tab {
        case .liked:     likedContent
        case .playlists: playlistsContent
        case .artists:   artistsContent
        }
    }

    // MARK: - Liked (Spotify list)

    private var likedContent: some View {
        VStack(spacing: 0) {
            if library.likedTracks.isEmpty {
                emptyState(icon: "heart.fill", color: .pink,
                           title: "Нет любимых треков",
                           subtitle: "Лайкайте треки в плеере")
            } else {
                // Play-all + shuffle row
                HStack(spacing: 12) {
                    Button {
                        player.play(library.likedTracks[0], queue: library.likedTracks)
                    } label: {
                        Image(systemName: "play.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.black)
                            .frame(width: 54, height: 54)
                            .background(Color.white, in: Circle())
                    }
                    .buttonStyle(.plain)

                    Button {
                        let shuffled = library.likedTracks.shuffled()
                        if let first = shuffled.first { player.play(first, queue: Array(shuffled.dropFirst())) }
                    } label: {
                        Image(systemName: "shuffle")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 54, height: 54)
                            .glassEffect(.regular.interactive(), in: Circle())
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text("\(library.likedTracks.count) треков")
                        .font(.caption).foregroundStyle(CrateColor.secondaryText)
                }
                .padding(.vertical, 16)

                VStack(spacing: 0) {
                    ForEach(Array(library.likedTracks.enumerated()), id: \.element.id) { idx, track in
                        likedRow(track: track, index: idx)
                        if idx < library.likedTracks.count - 1 {
                            Divider().background(Color.white.opacity(0.06)).padding(.leading, 70)
                        }
                    }
                }
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
        .padding(.top, 4)
    }

    private func likedRow(track: Track, index: Int) -> some View {
        HStack(spacing: 12) {
            CoverArtView(url: track.artworkURL, corner: 8)
                .frame(width: 48, height: 48)
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
        .padding(.horizontal, 14).padding(.vertical, 11)
        .contentShape(Rectangle())
        .onTapGesture { player.play(track, queue: library.likedTracks) }
    }

    // MARK: - Playlists (2-column grid)

    private var playlistsContent: some View {
        VStack(spacing: 12) {
            if library.playlists.isEmpty {
                emptyState(icon: "music.note.list", color: .purple,
                           title: "Нет плейлистов",
                           subtitle: "Нажмите «Создать плейлист»")
            } else {
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                    spacing: 12
                ) {
                    ForEach(library.playlists) { pl in
                        playlistCard(pl)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(.top, 4)
    }

    private func playlistCard(_ pl: Playlist) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        colors: [Color(red:0.10,green:0.08,blue:0.22),
                                 Color(red:0.05,green:0.04,blue:0.12)],
                        startPoint: .topLeading, endPoint: .bottomTrailing))
                if let url = pl.artworkURL {
                    CoverArtView(url: url, corner: 12)
                } else {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 30)).foregroundStyle(.white.opacity(0.7))
                }
            }
            .aspectRatio(1, contentMode: .fit)

            VStack(alignment: .leading, spacing: 2) {
                Text(pl.title).font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white).lineLimit(1)
                Text("\(pl.tracks.count) треков").font(.caption2)
                    .foregroundStyle(CrateColor.secondaryText)
            }
        }
        .padding(10)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onTapGesture {
            if let f = pl.tracks.first { player.play(f, queue: pl.tracks) }
        }
    }

    // MARK: - Artists

    private var artistsContent: some View {
        VStack(spacing: 0) {
            let artists: [(name: String, url: URL?, count: Int)] = Dictionary(
                grouping: library.likedTracks, by: \.artistName
            ).map { (name: $0.key, url: $0.value.first?.artworkURL, count: $0.value.count) }
             .sorted { $0.count > $1.count }

            if artists.isEmpty {
                emptyState(icon: "person.2.fill", color: .orange,
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
                                        .frame(width: 52, height: 52)
                                    if let url = a.url {
                                        CoverArtView(url: url, corner: 26)
                                            .frame(width: 52, height: 52)
                                            .clipShape(Circle())
                                    } else {
                                        Text(String(a.name.prefix(1)).uppercased())
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                }
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(a.name).font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.white).lineLimit(1)
                                    Text("\(a.count) треков")
                                        .font(.caption).foregroundStyle(CrateColor.secondaryText)
                                }
                                Spacer()
                                Image(systemName: "play.fill")
                                    .font(.system(size: 12)).foregroundStyle(CrateColor.secondaryText)
                            }
                            .padding(.horizontal, 14).padding(.vertical, 11)
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
                Circle().fill(color.opacity(0.15)).frame(width: 88, height: 88)
                Image(systemName: icon).font(.system(size: 34)).foregroundStyle(color.opacity(0.8))
            }
            .glassEffect(.regular, in: Circle())
            Text(title)
                .font(.custom("DelaGothicOne-Regular", size: 18)).foregroundStyle(.white)
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
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .glassEffect(.regular.interactive(), in: Capsule())
                }
                .buttonStyle(.plain)

                Button { showImport = true } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.down").font(.system(size: 13, weight: .semibold))
                        Text("Своя музыка").font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .glassEffect(.regular.interactive(), in: Capsule())
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
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 22))
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
                        Playlist(id: UUID().uuidString, title: t, subtitle: "Crate",
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
                        .glassEffect(.regular, in: Circle())
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
                    Button("Готово") { dismiss() }
                        .font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
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
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
