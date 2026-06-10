import Foundation

enum APIConfig {
    static let spotifyClientID = ""
    static let spotifyClientSecret = ""
    static let soundCloudClientID = ""
    static let lastFMAPIKey = ""
}

enum PlaybackConfig {
    static let preferredSources: [MusicSource] = [.yandex, .preview]
    static let yandexToken = ""
    static let yandexXToken = ""
    static let yandexUserID = 0
    static let yandexDeviceUUID = "monk-ios-client"
}
