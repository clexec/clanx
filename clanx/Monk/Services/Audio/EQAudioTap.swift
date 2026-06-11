import AVFoundation
import MediaToolbox

// MARK: - Biquad coefficients (Audio EQ Cookbook peaking EQ)

struct BiquadCoeffs {
    var b0: Float = 1; var b1: Float = 0; var b2: Float = 0
    var a1: Float = 0; var a2: Float = 0

    static let passthrough = BiquadCoeffs()

    static func peakEQ(freq: Float, gainDB: Float, sampleRate: Float, q: Float = 1.4) -> BiquadCoeffs {
        guard abs(gainDB) > 0.01 else { return .passthrough }
        let A  = pow(10, gainDB / 40)
        let w0 = 2 * Float.pi * freq / sampleRate
        let sinW0 = sin(w0), cosW0 = cos(w0)
        let alpha = sinW0 / (2 * q)
        let a0    = 1 + alpha / A
        return BiquadCoeffs(
            b0: (1 + alpha * A) / a0,
            b1: (-2 * cosW0)    / a0,
            b2: (1 - alpha * A) / a0,
            a1: (-2 * cosW0)    / a0,
            a2: (1 - alpha / A) / a0
        )
    }
}

// MARK: - Single band biquad filter (direct form II transposed, up to 8 channels)

final class BiquadFilter {
    var coeffs = BiquadCoeffs()
    private var s1 = [Float](repeating: 0, count: 8)
    private var s2 = [Float](repeating: 0, count: 8)

    func resetState() { s1 = Array(repeating: 0, count: 8); s2 = Array(repeating: 0, count: 8) }

    func process(samples: UnsafeMutablePointer<Float>, count: Int, channel: Int) {
        let c = coeffs
        var ls1 = s1[channel], ls2 = s2[channel]
        for i in 0..<count {
            let x = samples[i]
            let y = c.b0 * x + ls1
            ls1 = c.b1 * x - c.a1 * y + ls2
            ls2 = c.b2 * x - c.a2 * y
            samples[i] = y
        }
        s1[channel] = ls1; s2[channel] = ls2
    }
}

// MARK: - EQ Tap

final class EQAudioTap {
    private(set) var tap: MTAudioProcessingTap?
    private let filters: [BiquadFilter]
    var isEnabled: Bool = true
    var sampleRate: Float = 44100
    let bandFreqs: [Float] = [60, 160, 400, 1_000, 2_400, 16_000]

    init() {
        filters = bandFreqs.map { _ in BiquadFilter() }
        createTap()
    }

    func update(gains: [Float]) {
        for (i, freq) in bandFreqs.enumerated() {
            let g = i < gains.count ? gains[i] : 0
            filters[i].coeffs = .peakEQ(freq: freq, gainDB: g, sampleRate: sampleRate)
        }
    }

    func applyEQ(_ blPtr: UnsafeMutablePointer<AudioBufferList>, frameCount: Int) {
        guard isEnabled else { return }
        let bl = UnsafeMutableAudioBufferListPointer(blPtr)
        for (ch, buf) in bl.enumerated() {
            guard let data = buf.mData else { continue }
            let samples = data.assumingMemoryBound(to: Float.self)
            let n = Int(buf.mDataByteSize) / MemoryLayout<Float>.size
            for f in filters { f.process(samples: samples, count: n, channel: ch) }
        }
    }

    private func createTap() {
        let retained = Unmanaged.passRetained(self)

        var cbs = MTAudioProcessingTapCallbacks(
            version: kMTAudioProcessingTapCallbacksVersion_0,
            clientInfo: retained.toOpaque(),
            init: { _, clientInfo, tapStorage in tapStorage?.pointee = clientInfo },
            finalize: { tap in
                if let s = MTAudioProcessingTapGetStorage(tap) { Unmanaged<EQAudioTap>.fromOpaque(s).release() }
            },
            prepare: { tap, _, fmt in
                guard let s = MTAudioProcessingTapGetStorage(tap) else { return }
                let p = Unmanaged<EQAudioTap>.fromOpaque(s).takeUnretainedValue()
                p.sampleRate = Float(fmt.pointee.mSampleRate)
                p.update(gains: Array(repeating: 0, count: p.bandFreqs.count))
            },
            unprepare: { _ in },
            process: { tap, nFrames, _, blInOut, nOut, flagsOut in
                MTAudioProcessingTapGetSourceAudio(tap, nFrames, blInOut, flagsOut, nil, nOut)
                guard let s = MTAudioProcessingTapGetStorage(tap) else { return }
                Unmanaged<EQAudioTap>.fromOpaque(s).takeUnretainedValue()
                    .applyEQ(blInOut, frameCount: Int(nOut.pointee))
            }
        )

        var newTap: Unmanaged<MTAudioProcessingTap>?
        let status = MTAudioProcessingTapCreate(kCFAllocatorDefault, &cbs, kMTAudioProcessingTapCreationFlag_PostEffects, &newTap)
        if status == noErr {
            tap = newTap?.takeRetainedValue()
        } else {
            retained.release()
        }
    }
}

// MARK: - Attach to AVPlayerItem

extension EQAudioTap {
    func attach(to item: AVPlayerItem) {
        guard let processingTap = tap else { return }
        Task {
            do {
                let tracks = try await item.asset.loadTracks(withMediaType: .audio)
                guard let audioTrack = tracks.first else { return }
                let params = AVMutableAudioMixInputParameters(track: audioTrack)
                params.audioTapProcessor = processingTap
                let mix = AVMutableAudioMix()
                mix.inputParameters = [params]
                await MainActor.run { item.audioMix = mix }
            } catch {}
        }
    }
}
