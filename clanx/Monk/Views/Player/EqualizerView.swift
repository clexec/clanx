import SwiftUI

struct EqualizerView: View {
    @ObservedObject private var eq = EqualizerService.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            LinearGradient(
                colors: [Color(red:0.08,green:0.05,blue:0.15), Color.black],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar.padding(.bottom, 8)
                sliderSection.padding(.horizontal, 16)
                Divider().background(Color.white.opacity(0.08)).padding(.vertical, 8)
                presetList
            }
        }
    }

    // MARK: - Header with glass buttons

    private var headerBar: some View {
        HStack {
            Button("Готово") { dismiss() }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 18).padding(.vertical, 10)
                .glassEffect(.regular.interactive(), in: Capsule())

            Spacer()
            Text("Эквалайзер")
                .font(.custom("DelaGothicOne-Regular", size: 18))
                .foregroundStyle(.white)
            Spacer()

            Button("Сброс") {
                withAnimation(.spring(response: 0.32)) { eq.reset() }
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 18).padding(.vertical, 10)
            .glassEffect(.regular.interactive(), in: Capsule())
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    // MARK: - 6 vertical sliders in glass card

    private var sliderSection: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(0..<6, id: \.self) { i in
                EQBandColumn(
                    frequency: eq.bands[i],
                    gain: Binding(
                        get: { eq.gains[i] },
                        set: { eq.setGain($0, band: i) }
                    )
                )
            }
        }
        .frame(height: 220)
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    // MARK: - Preset list with glass rows

    private var presetList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 8) {
                ForEach(eq.presets, id: \.name) { preset in
                    Button {
                        withAnimation(.spring(response: 0.28)) {
                            eq.applyPreset(preset.name)
                        }
                    } label: {
                        HStack {
                            Text(preset.name)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.white)
                            Spacer()
                            if eq.selectedPreset == preset.name {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal, 20).padding(.vertical, 14)
                        .glassEffect(
                            eq.selectedPreset == preset.name ? .regular : .regular,
                            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                        )
                        .overlay(
                            eq.selectedPreset == preset.name
                            ? RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                            : nil
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Single band column

private struct EQBandColumn: View {
    let frequency: Float
    @Binding var gain: Float

    private var label: String {
        frequency >= 1000 ? "\(Int(frequency/1000))k" : "\(Int(frequency))"
    }

    var body: some View {
        VStack(spacing: 8) {
            EQVerticalSlider(gain: $gain)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(Color(white: 0.5))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Vertical EQ slider (same capsule style as player progress bar)

private struct EQVerticalSlider: View {
    @Binding var gain: Float
    private let range: ClosedRange<Float> = -12...12

    var body: some View {
        GeometryReader { geo in
            let h = geo.size.height
            let norm = CGFloat((gain - range.lowerBound) / (range.upperBound - range.lowerBound))
            let handleY = h * (1 - norm)
            let centerY = h * 0.5

            ZStack {
                // Track — same capsule style as player slider
                Capsule()
                    .fill(Color(white: 0.25))
                    .frame(width: 3)

                // Filled portion — pink like in screenshot
                let fillTop    = min(handleY, centerY)
                let fillHeight = max(2, abs(centerY - handleY))
                Capsule()
                    .fill(Color(red: 0.85, green: 0.1, blue: 0.45))
                    .frame(width: 3, height: fillHeight)
                    .position(x: geo.size.width / 2, y: fillTop + fillHeight / 2)

                // Handle — white pill matching player design
                Capsule()
                    .fill(Color.white)
                    .frame(width: 20, height: 32)
                    .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                    .position(x: geo.size.width / 2, y: handleY)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { v in
                        let proportion = Float(1.0 - v.location.y / h)
                        let clamped = max(0, min(1, proportion))
                        let raw = range.lowerBound + clamped * (range.upperBound - range.lowerBound)
                        gain = (raw * 4).rounded() / 4
                    }
            )
        }
    }
}
