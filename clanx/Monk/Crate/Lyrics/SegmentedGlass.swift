import SwiftUI

struct SegmentedGlass: View {
    @Binding var selection: Int
    let titles: [String]
    @Namespace private var namespace

    var body: some View {
        HStack(spacing: 4) {
            ForEach(titles.indices, id: \.self) { index in
                let active = selection == index
                Text(titles[index])
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(active ? .white : CrateColor.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background {
                        if active {
                            Capsule().fill(CrateColor.surfaceElevated)
                                .matchedGeometryEffect(id: "segment", in: namespace)
                        }
                    }
                    .contentShape(Capsule())
                    .onTapGesture { withAnimation(.snappy) { selection = index } }
            }
        }
        .padding(4)
        .crateGlass(Capsule())
    }
}
