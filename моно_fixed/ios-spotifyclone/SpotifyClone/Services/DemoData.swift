//
//  DemoData.swift
//  SpotifyClone
//
//  Bundled demo catalog used until a Yandex Music token is provided.
//  Audio uses freely-streamable sample clips so playback works out of the box.
//

import Foundation

/// Provides a rich demo catalog mirroring the shape of Yandex Music data.
enum DemoData {
    /// Royalty-free sample audio streams (Google sample bucket) so the player works without a token.
    private static let sampleAudio: [String] = [
        "https://storage.googleapis.com/media-session/sintel/snow-fight.mp3",
        "https://storage.googleapis.com/media-session/elephants-dream/the-wires.mp3",
        "https://storage.googleapis.com/media-session/big-buck-bunny/prelude.mp3",
        "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
        "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
        "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3",
        "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3",
        "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3"
    ]

    private static func cover(_ seed: String) -> String {
        "https://picsum.photos/seed/\(seed)/600/600"
    }

    private static func makeTrack(_ index: Int, title: String, artist: String, album: String, seed: String, duration: Int) -> Track {
        Track(
            id: "track-\(seed)-\(index)",
            title: title,
            artistName: artist,
            albumName: album,
            coverURL: cover(seed),
            audioURL: sampleAudio[index % sampleAudio.count],
            durationSeconds: duration
        )
    }

    // MARK: - Tracks

    static let popularTracks: [Track] = [
        makeTrack(0, title: "Midnight City Lights", artist: "Aurora Skye", album: "Neon Dreams", seed: "neon", duration: 213),
        makeTrack(1, title: "Velvet Horizon", artist: "The Lumen", album: "Afterglow", seed: "velvet", duration: 198),
        makeTrack(2, title: "Gravity", artist: "Echo Park", album: "Orbit", seed: "gravity", duration: 245),
        makeTrack(3, title: "Paper Planes", artist: "Maya Quinn", album: "Skylines", seed: "paper", duration: 187),
        makeTrack(4, title: "Electric Bloom", artist: "Violet Static", album: "Bloom", seed: "bloom", duration: 222),
        makeTrack(5, title: "Slow Tide", artist: "Coastline", album: "Shorebreak", seed: "tide", duration: 256),
        makeTrack(6, title: "Golden Hour", artist: "Aurora Skye", album: "Neon Dreams", seed: "golden", duration: 201),
        makeTrack(7, title: "Runaway", artist: "The Lumen", album: "Afterglow", seed: "runaway", duration: 234)
    ]

    static let chillTracks: [Track] = [
        makeTrack(2, title: "Soft Focus", artist: "Lull", album: "Quiet Rooms", seed: "softfocus", duration: 268),
        makeTrack(3, title: "Rainglass", artist: "Mono Leaf", album: "Petrichor", seed: "rainglass", duration: 240),
        makeTrack(4, title: "Driftwood", artist: "Coastline", album: "Shorebreak", seed: "driftwood", duration: 219),
        makeTrack(5, title: "Lavender", artist: "Violet Static", album: "Bloom", seed: "lavender", duration: 205),
        makeTrack(6, title: "Amber", artist: "Lull", album: "Quiet Rooms", seed: "amber", duration: 230)
    ]

    static let hitsTracks: [Track] = [
        makeTrack(1, title: "Supernova", artist: "Echo Park", album: "Orbit", seed: "supernova", duration: 211),
        makeTrack(0, title: "Heatwave", artist: "Maya Quinn", album: "Skylines", seed: "heatwave", duration: 195),
        makeTrack(7, title: "Wildfire", artist: "Violet Static", album: "Bloom", seed: "wildfire", duration: 248),
        makeTrack(2, title: "Diamonds", artist: "Aurora Skye", album: "Neon Dreams", seed: "diamonds", duration: 224)
    ]

    // MARK: - Albums

    static let albums: [Album] = [
        Album(id: "album-neon", title: "Neon Dreams", artistName: "Aurora Skye", coverURL: cover("neon"), year: 2024,
              tracks: Array(popularTracks.prefix(4))),
        Album(id: "album-afterglow", title: "Afterglow", artistName: "The Lumen", coverURL: cover("velvet"), year: 2023,
              tracks: Array(popularTracks.suffix(4))),
        Album(id: "album-orbit", title: "Orbit", artistName: "Echo Park", coverURL: cover("gravity"), year: 2025,
              tracks: hitsTracks),
        Album(id: "album-bloom", title: "Bloom", artistName: "Violet Static", coverURL: cover("bloom"), year: 2024,
              tracks: chillTracks)
    ]

    // MARK: - Artists

    static let artists: [Artist] = [
        Artist(id: "artist-aurora", name: "Aurora Skye", imageURL: cover("aurora"), genres: ["Synthpop", "Electronic"],
               topTracks: popularTracks.filter { $0.artistName == "Aurora Skye" }),
        Artist(id: "artist-lumen", name: "The Lumen", imageURL: cover("lumen"), genres: ["Indie", "Dream Pop"],
               topTracks: popularTracks.filter { $0.artistName == "The Lumen" }),
        Artist(id: "artist-echo", name: "Echo Park", imageURL: cover("echo"), genres: ["Alt Rock"],
               topTracks: hitsTracks.filter { $0.artistName == "Echo Park" }),
        Artist(id: "artist-violet", name: "Violet Static", imageURL: cover("violet"), genres: ["Electronic", "Pop"],
               topTracks: chillTracks.filter { $0.artistName == "Violet Static" })
    ]

    // MARK: - Playlists

    static let playlists: [Playlist] = [
        Playlist(id: "pl-daily", title: "Daily Mix 1", subtitle: "Aurora Skye, The Lumen and more",
                 coverURL: cover("daily1"), tracks: popularTracks),
        Playlist(id: "pl-chill", title: "Chill Vibes", subtitle: "Unwind and relax",
                 coverURL: cover("chill"), tracks: chillTracks),
        Playlist(id: "pl-hits", title: "Today's Top Hits", subtitle: "The hottest tracks right now",
                 coverURL: cover("hits"), tracks: hitsTracks),
        Playlist(id: "pl-focus", title: "Deep Focus", subtitle: "Keep calm and focus",
                 coverURL: cover("focus"), tracks: chillTracks.reversed()),
        Playlist(id: "pl-discover", title: "Discover Weekly", subtitle: "Your weekly mixtape of fresh music",
                 coverURL: cover("discover"), tracks: popularTracks.shuffled())
    ]

    // MARK: - Genres

    static let genres: [Genre] = [
        Genre(id: "g-pop", name: "Pop", colorSeed: "pop-pink"),
        Genre(id: "g-hiphop", name: "Hip-Hop", colorSeed: "hiphop-orange"),
        Genre(id: "g-rock", name: "Rock", colorSeed: "rock-red"),
        Genre(id: "g-electronic", name: "Electronic", colorSeed: "elec-cyan"),
        Genre(id: "g-chill", name: "Chill", colorSeed: "chill-teal"),
        Genre(id: "g-indie", name: "Indie", colorSeed: "indie-purple"),
        Genre(id: "g-jazz", name: "Jazz", colorSeed: "jazz-amber"),
        Genre(id: "g-classical", name: "Classical", colorSeed: "classical-blue"),
        Genre(id: "g-rnb", name: "R&B", colorSeed: "rnb-magenta"),
        Genre(id: "g-mood", name: "Mood", colorSeed: "mood-green")
    ]

    /// All tracks flattened for naive local search.
    static var allTracks: [Track] {
        popularTracks + chillTracks + hitsTracks
    }
}
