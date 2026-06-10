import SwiftUI

struct EqualizerView: View {
    @ObservedObject private var eq = EqualizerService.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            sliderSection
                .padding(.top, 16)
            Divider().background(Color.white.opacity(0.08))
            presetList
        }
        .background(Color(white: 0.07).ignoresSafeArea())
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            Button("Готово") { dismiss() }
                .font(.delaBody)
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(.ultraThinMaterial, in: Capsule())

            Spacer()

            Text("Эквалайзер")
                .font(.delaHeadline)
                .foregroundStyle(.white)

            Spacer()

            Button("Сброс") {
                withAnimation(.spring(response: 0.35)) { eq.reset() }
            }
            .font(.delaBody)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .background(.ultraThinMaterial, in: Capsule())
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }

    // MARK: - Sliders

    private var sliderSection: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(0..<6, id: \.self) { i in
                EQBandSlider(
                    frequency: eq.bands[i],
                    gain: Binding(get: { eq.gains[i] }, set: { eq.setGain($0, band: i) })
                )
            }
        }
        .frame(height: 230)
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color(white: 0.12), in: RoundedRectangle(cornerRadius: 18))
        .padding(.horizontal, 16)
    }

    // MARK: - Preset list

    private var presetList: some View {
        List {
            ForEach(eq.presets, id: \.name) { preset in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        eq.applyPreset(preset.name)
                    }
                } label: {
                    HStack {
                        Text(preset.name)
                            .font(.delaBody)
                            .foregroundStyle(.white)
                        Spacer()
                        if eq.selectedPreset == preset.name {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(ColorPalette.accent)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(Color.white.opacity(0.08))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(white: 0.07))
    }
}

// MARK: - Single EQ band slider

private struct EQBandSlider: View {
    let frequency: Float
    @Binding var gain: Float

    private var freqLabel: String {
        frequency >= 1000 ? "\(Int(frequency/1000))k" : "\(Int(frequency))"
    }

    var body: some View {
        VStack(spacing: 6) {
            VerticalEQSlider(value: Binding(
                get: { Double(gain) },
                set: { gain = Float($0) }
            ))

            Text(freqLabel)
                .font(.system(size: 10))
                .foregroundStyle(Color(white: 0.55))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Vertical slider

private struct VerticalEQSlider: View {
    @Binding var value: Double
    private let range: ClosedRange<Double> = -12...12

    private func normalized(_ h: CGFloat) -> CGFloat {
        CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
    }

    var body: some View {
        GeometryReader { geo in
            let h = geo.size.height
            let norm = normalized(h)
            let handleY = h * (1 - norm)           // 0 = top

            ZStack {
                // Track background
                Capsule()
                    .fill(Color(white: 0.3))
                    .frame(width: 3)

                // Active fill (pink, from center to handle)
                let centerY = h * 0.5
                let fillTop = min(handleY, centerY)
                let fillH = abs(centerY - handleY)
                Capsule()
                    .fill(Color(red: 1, green: 0.18, blue: 0.55))  // #FF2E8C
                    .frame(width: 3, height: max(2, fillH))
                    .position(x: geo.size.width / 2,
                              y: fillTop + fillH / 2)

                // Handle (white pill)
                Capsule()
                    .fill(Color.white)
                    .frame(width: 22, height: 34)
                    .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
                    .position(x: geo.size.width / 2, y: handleY)
            }
            .frame(width: geo.size.width)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { v in
                        let proportion = 1.0 - Double(v.location.y / h)
                        let clamped = max(0, min(1, proportion))
                        let raw = range.lowerBound + clamped * (range.upperBound - range.lowerBound)
                        value = (raw * 4).rounded() / 4  // snap to 0.25 dB steps
                    }
            )
        }
    }
}

#Preview {
    EqualizerView()
}
