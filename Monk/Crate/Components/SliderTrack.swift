import SwiftUI

struct SliderTrack: View {
    @Binding var value: Double
    var total: Double = 1
    var height: CGFloat = 4
    var knob: CGFloat = 14

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let ratio = total > 0 ? CGFloat(value / total) : 0
            ZStack(alignment: .leading) {
                Capsule().fill(CrateColor.surfaceElevated).frame(height: height)
                Capsule().fill(.white).frame(width: max(knob / 2, width * ratio), height: height)
                Circle().fill(.white)
                    .frame(width: knob, height: knob)
                    .offset(x: min(max(0, width * ratio - knob / 2), width - knob))
            }
            .frame(height: knob)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0).onChanged { drag in
                    value = Double(min(max(0, drag.location.x / width), 1)) * total
                }
            )
        }
        .frame(height: knob)
    }
}
