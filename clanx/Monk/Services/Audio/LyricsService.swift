import Foundation

// Fetches plain lyrics from lrclib.net — free, no API key required.
struct LyricsService {
    static func fetch(title: String, artist: String) async -> String? {
        var comps = URLComponents(string: "https://lrclib.net/api/get")!
        comps.queryItems = [
            URLQueryItem(name: "artist_name", value: artist),
            URLQueryItem(name: "track_name",  value: title)
        ]
        guard let url = comps.url else { return nil }
        do {
            let (data, resp) = try await URLSession.shared.data(from: url)
            guard (resp as? HTTPURLResponse)?.statusCode == 200 else { return nil }
            let decoded = try JSONDecoder().decode(LRCLibResponse.self, from: data)
            // Prefer plain lyrics, fallback to syncedLyrics stripped of timestamps
            if let plain = decoded.plainLyrics, !plain.isEmpty { return plain }
            if let synced = decoded.syncedLyrics {
                let stripped = synced.split(separator: "\n").map { line -> String in
                    // Remove [mm:ss.xx] timestamp prefix
                    let s = String(line)
                    if s.hasPrefix("[") { return String(s.drop(while: { $0 != "]" }).dropFirst()) }
                    return s
                }.joined(separator: "\n")
                return stripped.isEmpty ? nil : stripped
            }
            return nil
        } catch {
            return nil
        }
    }
}

private struct LRCLibResponse: Decodable {
    let plainLyrics: String?
    let syncedLyrics: String?
}
