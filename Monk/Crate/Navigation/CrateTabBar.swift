import SwiftUI

struct CrateTabBar: View {
    @Binding var selection: Int
    let onSearch: () -> Void

    private let items: [(symbol: String, ru: String, en: String)] = [
        ("house.fill", "Главная", "Home"),
        ("heart", "Избранное", "Favorites"),
        ("person", "Профиль", "Profile")
    ]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(items.indices, id: \.self) { index in
                tabButton(index)
            }
            Spacer(minLength: 0)
            searchButton
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }

    private func tabButton(_ index: Int) -> some View {
        let active = selection == index
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                selection = index
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: items[index].symbol)
                    .font(.system(size: 17, weight: .semibold))
                if active {
                    Text(bi(items[index].ru, items[index].en))
                        .font(.subheadline.weight(.semibold))
                        .transition(.opacity.combined(with: .scale(scale: 0.8, anchor: .leading)))
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, active ? 18 : 14)
            .padding(.vertical, 13)
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .glassEffect(.regular, in: Capsule())
    }

    private var searchButton: some View {
        Button(action: onSearch) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .glassEffect(.regular, in: Circle())
    }
}
