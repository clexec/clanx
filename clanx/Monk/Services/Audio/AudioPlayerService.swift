import AVFoundation
import Combine
import Foundation

@MainActor
final class AudioPlayerService: ObservableObject {
    @Published private(set) var state: PlaybackState = .idle
    @Published private(set) var currentTime: Double = 0
    @Published private(set) var duration: Double = 30
    @Published var volume: Float = 0.8 {
        didSet { playerNode?.volume = volume }
    }

    // AVAudioEngine for EQ support
    private let engine = AVAudioEngine()
    private let playerNode = AVPlayerNode()
    private let eq: AVAudioUnitEQ

    // Legacy AVPlayer for stream URLs (YouTube / JioSaavn full tracks)
    private var legacyPlayer: AVPlayer?
    private var usingEngine = false

    private var timeObserver: Any?
    private var statusObserver: NSKeyValueObservation?
    private var endObserver: NSObjectProtocol?
    private let streamProvider = PlaybackStreamProvider()
    private var loadTask: Task<Void, Never>?
    var onTrackEnd: (() -> Void)?

    init() {
        eq = EqualizerService.shared.eq
        setupEngine()
    }

    // MARK: - Engine setup

    private func setupEngine() {
        engine.attach(playerNode)
        engine.attach(eq)
        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        engine.connect(playerNode, to: eq, format: format)
        engine.connect(eq, to: engine.mainMixerNode, format: format)
        try? engine.start()
    }

    // MARK: - Play

    func play(track: Track) {
        loadTask?.cancel()
        stopAll()
        duration = Double(max(track.durationMillis, 30_000)) / 1000

        if let previewURL = track.previewURL {
            startLegacy(url: previewURL)
            duration = 30
        } else {
            state = .loading
        }

        loadTask = Task { [weak self] in
            guard let self, !Task.isCancelled else { return }
            if let url = await self.streamProvider.streamURL(for: track),
               url != track.previewURL, !Task.isCancelled {
                self.startLegacy(url: url)
                self.duration = Double(max(track.durationMillis, 30_000)) / 1000
            }
        }
    }

    private func startLegacy(url: URL) {
        stopAll()
        usingEngine = false
        let item = AVPlayerItem(url: url)
        legacyPlayer = AVPlayer(playerItem: item)
        legacyPlayer?.volume = volume
        addLegacyObservers(item: item)
        legacyPlayer?.play()
        state = .playing
    }

    // MARK: - Controls

    func toggle() {
        if state == .playing {
            legacyPlayer?.pause()
            state = .paused
        } else {
            legacyPlayer?.play()
            state = .playing
        }
    }

    func seek(to value: Double) {
        let clamped = max(0, min(value, duration))
        legacyPlayer?.seek(to: CMTime(seconds: clamped, preferredTimescale: 600))
        currentTime = clamped
    }

    // MARK: - Observers

    private func addLegacyObservers(item: AVPlayerItem) {
        timeObserver = legacyPlayer?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.1, preferredTimescale: 600),
            queue: .main
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
        // Auto-advance to next track
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.state = .idle
                self?.onTrackEnd?()
            }
        }
    }

    private func stopAll() {
        if let obs = timeObserver, let p = legacyPlayer { p.removeTimeObserver(obs) }
        if let obs = endObserver { NotificationCenter.default.removeObserver(obs) }
        timeObserver = nil
        statusObserver = nil
        endObserver = nil
        legacyPlayer?.pause()
        legacyPlayer = nil
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
