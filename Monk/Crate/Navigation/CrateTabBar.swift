import SwiftUI

struct CrateTabBar: View {
    @Binding var selection: Int
    let onSearch: () -> Void

    private let items: [(symbol: String, ru: String, en: String)] = [
        ("house.fill",  "Главная",   "Home"),
        ("heart.fill",  "Избранное", "Favorites"),
        ("person.fill", "Профиль",   "Profile")
    ]

    private let accent = Color(red: 0.85, green: 0.55, blue: 0.30)

    var body: some View {
        HStack(spacing: 10) {
            // Main tab capsule — 3 tabs inside one glass pill
            HStack(spacing: 0) {
                ForEach(items.indices, id: \.self) { tabItem($0) }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .glassEffect(.regular, in: Capsule())

            // Search — separate standalone glass circle
            Button(action: onSearch) {
                VStack(spacing: 3) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                    Text(bi("Поиск", "Search"))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 6)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .glassEffect(.regular, in: Capsule())
        }
    }

    @ViewBuilder
    private func tabItem(_ index: Int) -> some View {
        let active = selection == index
        Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.7)) {
                selection = index
            }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: items[index].symbol)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(active ? accent : .white)
                    .frame(width: 44, height: 44)
                    .background {
                        if active {
                            Circle()
                                .fill(.white.opacity(0.14))
                                .transition(.scale(scale: 0.6).combined(with: .opacity))
                        }
                    }
                Text(bi(items[index].ru, items[index].en))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(active ? 1.0 : 0.6))
            }
            .padding(.horizontal, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.28, dampingFraction: 0.7), value: active)
    }
}
