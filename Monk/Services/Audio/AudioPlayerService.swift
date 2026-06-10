import AVFoundation
import Combine
import Foundation

@MainActor
final class AudioPlayerService: ObservableObject {
    @Published private(set) var state: PlaybackState = .idle
    @Published private(set) var currentTime: Double = 0
    @Published private(set) var duration: Double = 30
    @Published var volume: Float = 0.8 { didSet { player?.volume = volume } }

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var statusObserver: NSKeyValueObservation?
    private let streamProvider = PlaybackStreamProvider()
    private var loadTask: Task<Void, Never>?

    func play(track: Track) {
        loadTask?.cancel()
        removeObserver()
        duration = Double(max(track.durationMillis, 30_000)) / 1000
        loadTask = Task { [weak self] in
            guard let self, let url = await self.streamProvider.streamURL(for: track), !Task.isCancelled else { return }
            self.startPlayback(url: url)
        }
    }

    private func startPlayback(url: URL) {
        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)
        player?.volume = volume
        addObserver()
        player?.play()
        state = .playing
    }

    func toggle() {
        if state == .playing {
            player?.pause()
            state = .paused
        } else {
            player?.play()
            state = .playing
        }
    }

    func seek(to value: Double) {
        let clamped = max(0, min(value, duration))
        player?.seek(to: CMTime(seconds: clamped, preferredTimescale: 600))
        currentTime = clamped
    }

    private func addObserver() {
        // Update time every 0.1s for smooth progress bar
        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.1, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            Task { @MainActor in
                let seconds = time.seconds
                self?.currentTime = seconds.isFinite ? seconds : 0
            }
        }

        // Observe item status for real duration
        if let item = player?.currentItem {
            statusObserver = item.observe(\.duration, options: .new) { [weak self] item, _ in
                Task { @MainActor in
                    let dur = item.duration.seconds
                    if dur.isFinite && dur > 0 {
                        self?.duration = dur
                    }
                }
            }
        }
    }

    private func removeObserver() {
        if let timeObserver, let player { player.removeTimeObserver(timeObserver) }
        timeObserver = nil
        statusObserver = nil
    }
}

struct AudioSessionManager {
    func configure() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
}

final class AVPlayerDelegate: NSObject {}
