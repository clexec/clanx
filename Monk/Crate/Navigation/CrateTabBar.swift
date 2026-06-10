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
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                ForEach(items.indices, id: \.self) { index in
                    tab(index)
                }
            }
            .padding(6)
            .contentShape(Capsule())
            .glassEffect(.regular, in: Capsule())

            Button(action: onSearch) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .glassEffect(.regular, in: Circle())
        }
    }

    private func tab(_ index: Int) -> some View {
        let active = selection == index
        return Button {
            selection = index
        } label: {
            HStack(spacing: 6) {
                Image(systemName: items[index].symbol)
                if active {
                    Text(bi(items[index].ru, items[index].en))
                        .font(.footnote.weight(.semibold))
                }
            }
            .foregroundStyle(active ? .white : CrateColor.secondaryText)
            .padding(.horizontal, active ? 16 : 12)
            .padding(.vertical, 10)
            .background { if active { Capsule().fill(CrateColor.surfaceElevated) } }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
