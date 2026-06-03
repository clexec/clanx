import SwiftUI

@main
struct SpotifyCloneApp: App {
    init() {
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
