import AVFoundation
import Combine

// Manages AVAudioUnitEQ bands and presets.
// AudioPlayerService routes output through this engine when EQ is enabled.
@MainActor
final class EqualizerService: ObservableObject {
    static let shared = EqualizerService()

    let bands: [Float] = [60, 160, 400, 1_000, 2_400, 16_000]

    @Published var gains: [Float]      = Array(repeating: 0, count: 6)
    @Published var selectedPreset: String? = nil
    @Published var isEnabled: Bool     = true

    // AVAudioUnitEQ — attached to the shared AVAudioEngine in AudioPlayerService
    let eq: AVAudioUnitEQ = {
        let unit = AVAudioUnitEQ(numberOfBands: 6)
        let freqs: [Float] = [60, 160, 400, 1_000, 2_400, 16_000]
        for (i, f) in freqs.enumerated() {
            unit.bands[i].filterType  = .parametric
            unit.bands[i].frequency   = f
            unit.bands[i].bandwidth   = 1.0
            unit.bands[i].gain        = 0
            unit.bands[i].bypass      = false
        }
        return unit
    }()

    let presets: [(name: String, gains: [Float])] = [
        ("Dance",       [ 5,  3,  0,  1,  3,  2]),
        ("Deep",        [ 5,  3,  1,  0, -2, -4]),
        ("Electronic",  [ 4,  1, -1, -2,  2,  4]),
        ("Flat",        [ 0,  0,  0,  0,  0,  0]),
        ("Hip-Hop",     [ 5,  3,  0, -1,  1,  3]),
        ("Jazz",        [ 3,  1,  0,  0,  1,  3]),
        ("Latin",       [ 4,  0, -2, -2,  0,  4]),
        ("Pop",         [-1,  2,  4,  4,  2, -1]),
        ("R&B",         [ 4,  3,  0, -1,  2,  3]),
        ("Rock",        [ 5,  3, -1, -1,  2,  4]),
    ]

    private init() {}

    func setGain(_ gain: Float, band: Int) {
        gains[band] = gain
        eq.bands[band].gain = gain
        selectedPreset = nil
    }

    func applyPreset(_ name: String) {
        guard let preset = presets.first(where: { $0.name == name }) else { return }
        for (i, g) in preset.gains.enumerated() {
            gains[i] = g
            eq.bands[i].gain = g
        }
        selectedPreset = name
    }

    func reset() {
        for i in 0..<6 { gains[i] = 0; eq.bands[i].gain = 0 }
        selectedPreset = nil
    }
}
