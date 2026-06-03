//
//  AudioPlayer.swift
//  SpotifyClone
//
//  Observable audio engine driving the mini-player and full player.
//  Manages an AVPlayer, the active queue, progress and playback state.
//

import Foundation
import AVFoundation
import Combine

/// Global playback controller shared across the app.
@Observable
final class AudioPlayer {
    static let shared = AudioPlayer()

    private(set) var queue: [Track] = []
    private(set) var currentIndex: Int = 0

    var currentTrack: Track? {
        guard queue.indices.contains(currentIndex) else { return nil }
        return queue[currentIndex]
    }

    var isPlaying: Bool = false
    var progress: Double = 0          // 0...1
    var currentTime: Double = 0       // seconds
    var duration: Double = 0          // seconds
    var isLoading: Bool = false
    var shuffleEnabled: Bool = false
    var repeatEnabled: Bool = false

    /// Yandex token provider, injected by the app for real streaming.
    var tokenProvider: () -> String = { "" }

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var endObserver: NSObjectProtocol?

    private init() {
        configureSession()
    }

    private func configureSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[AudioPlayer] session error: \(error.localizedDescription)")
        }
    }

    // MARK: - Public controls

    /// Begin playing a list of tracks starting at the given track.
    func play(_ track: Track, in tracks: [Track]) {
        queue = tracks.isEmpty ? [track] : tracks
        currentIndex = queue.firstIndex(of: track) ?? 0
        loadCurrent()
    }

    func togglePlayPause() {
        guard let player else { return }
        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }

    func next() {
        guard !queue.isEmpty else { return }
        if shuffleEnabled {
            currentIndex = Int.random(in: 0..<queue.count)
        } else {
            currentIndex = (currentIndex + 1) % queue.count
        }
        loadCurrent()
    }

    func previous() {
        guard !queue.isEmpty else { return }
        if currentTime > 3 {
            seek(to: 0)
            return
        }
        currentIndex = (currentIndex - 1 + queue.count) % queue.count
        loadCurrent()
    }

    func seek(to fraction: Double) {
        guard let player, duration > 0 else { return }
        let target = CMTime(seconds: fraction * duration, preferredTimescale: 600)
        player.seek(to: target)
    }

    // MARK: - Loading

    private func loadCurrent() {
        guard let track = currentTrack else { return }
        isLoading = true
        progress = 0
        currentTime = 0
        duration = Double(track.durationSeconds)

        Task { @MainActor in
            let url = await resolveURL(for: track)
            guard let url else {
                isLoading = false
                return
            }
            startPlayback(url: url)
        }
    }

    private func resolveURL(for track: Track) async -> URL? {
        // Direct URL (demo data) takes priority.
        if let direct = track.audioURL, let url = URL(string: direct) {
            return url
        }
        // Otherwise resolve through Yandex Music when a token is present.
        let token = tokenProvider()
        guard !token.isEmpty else { return nil }
        do {
            return try await YandexMusicService.shared.streamURL(trackId: track.id, token: token)
        } catch {
            print("[AudioPlayer] stream resolve failed: \(error.localizedDescription)")
            return nil
        }
    }

    private func startPlayback(url: URL) {
        removeObservers()
        let item = AVPlayerItem(url: url)
        let newPlayer = AVPlayer(playerItem: item)
        player = newPlayer

        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = newPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self else { return }
            let seconds = time.seconds
            self.currentTime = seconds
            if let itemDuration = newPlayer.currentItem?.duration.seconds, itemDuration.isFinite, itemDuration > 0 {
                self.duration = itemDuration
                self.progress = seconds / itemDuration
            } else if self.duration > 0 {
                self.progress = seconds / self.duration
            }
            if self.isLoading, newPlayer.currentItem?.status == .readyToPlay {
                self.isLoading = false
            }
        }

        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            if self.repeatEnabled {
                self.seek(to: 0)
                self.player?.play()
            } else {
                self.next()
            }
        }

        newPlayer.play()
        isPlaying = true
        isLoading = false
    }

    private func removeObservers() {
        if let timeObserver { player?.removeTimeObserver(timeObserver) }
        timeObserver = nil
        if let endObserver { NotificationCenter.default.removeObserver(endObserver) }
        endObserver = nil
    }
}
