import SwiftUI

struct CrateTabBar: View {
    @Binding var selection: Int
    let onSearch: () -> Void

    private let items: [(symbol: String, ru: String, en: String)] = [
        ("house.fill",  "Главная",   "Home"),
        ("heart",       "Избранное", "Favorites"),
        ("person",      "Профиль",   "Profile")
    ]

    var body: some View {
        // GlassEffectContainer — обязателен, иначе стекло не сливается
        GlassEffectContainer(spacing: 10) {
            HStack(spacing: 10) {
                ForEach(items.indices, id: \.self) { index in
                    tabButton(index)
                }
                searchButton
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
            HStack(spacing: 6) {
                Image(systemName: items[index].symbol)
                    .font(.system(size: 16, weight: .semibold))
                if active {
                    Text(bi(items[index].ru, items[index].en))
                        .font(.subheadline.weight(.semibold))
                        .transition(.opacity.combined(with: .scale(scale: 0.75, anchor: .leading)))
                }
            }
            .foregroundStyle(.white.opacity(active ? 1.0 : 0.55))
            .padding(.horizontal, active ? 18 : 14)
            .padding(.vertical, 12)
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        // Каждая кнопка — свой glass элемент, .interactive() нужен для тапов
        .glassEffect(.regular.interactive(), in: Capsule())
        .animation(.spring(response: 0.32, dampingFraction: 0.72), value: active)
    }

    private var searchButton: some View {
        Button(action: onSearch) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: Circle())
    }
}
