//
//  SpotifyCloneApp.swift
//  SpotifyClone
//
//  App entry point. Wires the audio player to the library's Yandex token
//  and launches straight into the main tab experience (no auth gate).
//

import SwiftUI

@main
struct SpotifyCloneApp: App {
    init() {
        // Provide the Yandex token to the audio player for real streaming.
        AudioPlayer.shared.tokenProvider = { LibraryStore.shared.token }
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.dark)
                .tint(Theme.accent)
        }
    }
}
