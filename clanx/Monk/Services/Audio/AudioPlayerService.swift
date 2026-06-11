import AVFoundation
import Combine
import Foundation

@MainActor
final class AudioPlayerService: ObservableObject {
    @Published private(set) var state: PlaybackState = .idle
    @Published private(set) var currentTime: Double = 0
    @Published private(set) var duration: Double = 30
    @Published var volume: Float = 0.8 {
        didSet { player?.volume = volume }
    }

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var statusObserver: NSKeyValueObservation?
    private var endObserver: NSObjectProtocol?
    private let streamProvider = PlaybackStreamProvider()
    private var loadTask: Task<Void, Never>?
    private var eqTap: EQAudioTap?
    private var eqCancellable: AnyCancellable?
    var onTrackEnd: (() -> Void)?

    init() {
        eqCancellable = EqualizerService.shared.$gains
            .receive(on: DispatchQueue.main)
            .sink { [weak self] gains in
                self?.eqTap?.update(gains: gains)
            }
    }

    // MARK: - Play

    func play(track: Track) {
        loadTask?.cancel()
        stopAll()
        duration = Double(max(track.durationMillis, 30_000)) / 1000

        if let previewURL = track.previewURL {
            startPlayback(url: previewURL)
            duration = 30
        } else {
            state = .loading
        }

        loadTask = Task { [weak self] in
            guard let self, !Task.isCancelled else { return }
            if let url = await self.streamProvider.streamURL(for: track),
               url != track.previewURL, !Task.isCancelled {
                self.startPlayback(url: url)
                self.duration = Double(max(track.durationMillis, 30_000)) / 1000
            }
        }
    }

    private func startPlayback(url: URL) {
        stopAll()
        let item = AVPlayerItem(url: url)
        // Attach EQ tap
        let tap = EQAudioTap()
        tap.isEnabled = EqualizerService.shared.isEnabled
        tap.update(gains: EqualizerService.shared.gains)
        tap.attach(to: item)
        eqTap = tap
        player = AVPlayer(playerItem: item)
        player?.volume = volume
        addObservers(item: item)
        player?.play()
        state = .playing
    }

    // MARK: - Controls

    func toggle() {
        if state == .playing { player?.pause(); state = .paused }
        else { player?.play(); state = .playing }
    }

    func seek(to value: Double) {
        let clamped = max(0, min(value, duration))
        player?.seek(to: CMTime(seconds: clamped, preferredTimescale: 600))
        currentTime = clamped
    }

    // MARK: - Observers

    private func addObservers(item: AVPlayerItem) {
        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.1, preferredTimescale: 600), queue: .main
        ) { [weak self] time in
            Task { @MainActor in
                let s = time.seconds
                self?.currentTime = s.isFinite ? s : 0
            }
        }
        statusObserver = item.observe(\.duration, options: .new) { [weak self] it, _ in
            Task { @MainActor in
                let d = it.duration.seconds
                if d.isFinite && d > 0 { self?.duration = d }
            }
        }
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.state = .idle
                self?.onTrackEnd?()
            }
        }
    }

    private func stopAll() {
        if let obs = timeObserver, let p = player { p.removeTimeObserver(obs) }
        if let obs = endObserver { NotificationCenter.default.removeObserver(obs) }
        timeObserver = nil; statusObserver = nil; endObserver = nil
        player?.pause(); player = nil
        eqTap = nil
        currentTime = 0
    }
}

struct AudioSessionManager {
    func configure() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
}

final class AVPlayerDelegate: NSObject {}
