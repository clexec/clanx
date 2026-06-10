import SwiftUI

struct CrateProfileScreen: View {
    @EnvironmentObject private var auth: AuthenticationManager

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                Text(bi("Профиль", "Profile")).font(.title2.bold()).foregroundStyle(.white)
                Image(systemName: "person.crop.circle.fill")
                    .resizable().frame(width: 96, height: 96).foregroundStyle(CrateColor.surfaceElevated)
                Text(auth.currentUser?.displayName ?? bi("Гость", "Guest"))
                    .font(.title3.bold()).foregroundStyle(.white)
                if let email = auth.currentUser?.email {
                    Text(email).font(.subheadline).foregroundStyle(CrateColor.secondaryText)
                }
            }
            .frame(maxWidth: .infinity).padding(.top, 20).padding(.bottom, 170)
        }
        .background(CrateColor.background)
    }
}
