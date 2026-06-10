import SwiftUI

struct CrateProfileScreen: View {
    @EnvironmentObject private var auth: AuthenticationManager

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                Text(bi("Профиль", "Profile"))
                    .font(.title2.bold()).foregroundStyle(.white)

                VStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable().frame(width: 96, height: 96)
                        .foregroundStyle(CrateColor.secondaryText)
                    Text(auth.currentUser?.displayName ?? bi("Гость", "Guest"))
                        .font(.title3.bold()).foregroundStyle(.white)
                    if let email = auth.currentUser?.email {
                        Text(email).font(.subheadline).foregroundStyle(CrateColor.secondaryText)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .crateGlass(RoundedRectangle(cornerRadius: 24, style: .continuous))

                VStack(spacing: 1) {
                    profileRow(icon: "music.note.list", title: bi("Моя библиотека", "My Library")) {}
                    profileRow(icon: "bell", title: bi("Уведомления", "Notifications")) {}
                    profileRow(icon: "lock.shield", title: bi("Конфиденциальность", "Privacy")) {}
                }
                .crateGlass(RoundedRectangle(cornerRadius: 20, style: .continuous))

                if auth.currentUser != nil {
                    Button {
                        Task { try? await auth.signOut() }
                    } label: {
                        Label(bi("Выйти", "Sign Out"), systemImage: "rectangle.portrait.and.arrow.right")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .crateGlass(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
            }
            .padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 170)
        }
        .background(CrateColor.background)
    }

    private func profileRow(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16)).foregroundStyle(.white)
                    .frame(width: 28)
                Text(title).font(.subheadline).foregroundStyle(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CrateColor.secondaryText)
            }
            .padding(.horizontal, 18).padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
