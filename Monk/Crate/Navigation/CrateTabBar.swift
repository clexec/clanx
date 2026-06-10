import SwiftUI

// Proper iOS 26 Liquid Glass nav bar using GlassEffectContainer
struct CrateTabBar: View {
    @Binding var selection: Int
    let onSearch: () -> Void

    private let items: [(symbol: String, ru: String, en: String)] = [
        ("house.fill",  "Главная",   "Home"),
        ("heart",       "Избранное", "Favorites"),
        ("person",      "Профиль",   "Profile")
    ]

    var body: some View {
        // GlassEffectContainer required for adjacent glass elements to merge
        GlassEffectContainer(spacing: 8) {
            HStack(spacing: 4) {
                // Unified tab group — single glass capsule
                HStack(spacing: 0) {
                    ForEach(items.indices, id: \.self) { tabButton($0) }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 6)
                .glassEffect(.regular, in: Capsule())

                // Search button — separate glass circle that merges with tab bar
                Button(action: onSearch) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 50, height: 50)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: Circle())
            }
        }
    }

    @ViewBuilder
    private func tabButton(_ index: Int) -> some View {
        let active = selection == index
        Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.72)) {
                selection = index
            }
        } label: {
            HStack(spacing: active ? 6 : 0) {
                Image(systemName: items[index].symbol)
                    .font(.system(size: 16, weight: .semibold))
                if active {
                    Text(bi(items[index].ru, items[index].en))
                        .font(.subheadline.weight(.semibold))
                        .transition(.opacity.combined(with: .scale(scale: 0.75, anchor: .leading)))
                }
            }
            .foregroundStyle(active ? .white : .white.opacity(0.5))
            .padding(.horizontal, active ? 16 : 14)
            .padding(.vertical, 10)
            .background {
                if active {
                    Capsule().fill(.white.opacity(0.2)).transition(.opacity)
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.32, dampingFraction: 0.72), value: active)
    }
}
