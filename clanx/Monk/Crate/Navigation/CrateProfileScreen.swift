import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI
import SwiftUI

// MARK: - App Logo (синяя звезда как в иконке)

struct CrateLogoIcon: View {
    var size: CGFloat = 48
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22)
                .fill(LinearGradient(
                    colors: [Color(red: 0.22, green: 0.55, blue: 1.0),
                             Color(red: 0.05, green: 0.28, blue: 0.92)],
                    startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: size, height: size)
            // Кольцо-орбита
            Ellipse()
                .stroke(Color.white.opacity(0.55), lineWidth: size * 0.03)
                .frame(width: size * 0.82, height: size * 0.26)
                .rotationEffect(.degrees(-20))
            // Большая звезда
            Image(systemName: "sparkle")
                .font(.system(size: size * 0.42, weight: .bold))
                .foregroundStyle(.white)
                .offset(x: size * 0.02, y: -size * 0.02)
            // Маленькая звезда
            Image(systemName: "sparkle")
                .font(.system(size: size * 0.18, weight: .bold))
                .foregroundStyle(.white.opacity(0.9))
                .offset(x: -size * 0.22, y: size * 0.2)
        }
    }
}

// MARK: - QR Code generator

private func generateQR(from text: String) -> UIImage? {
    let ctx = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    filter.message = Data(text.utf8)
    filter.correctionLevel = "M"
    guard let output = filter.outputImage else { return nil }
    let scaled = output.transformed(by: CGAffineTransform(scaleX: 12, y: 12))
    guard let cg = ctx.createCGImage(scaled, from: scaled.extent) else { return nil }
    return UIImage(cgImage: cg)
}

// MARK: - Profile Screen

struct CrateProfileScreen: View {
    @EnvironmentObject private var auth: AuthenticationManager
    @State private var showEdit = false
    @State private var showQR   = false

    var body: some View {
        ZStack {
            CrateColor.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    topBar
                    avatarSection
                    menuSection
                    signOutSection
                }
                .padding(.bottom, 180)
            }
        }
        .sheet(isPresented: $showEdit) {
            EditProfileSheet()
                .environmentObject(auth)
        }
        .sheet(isPresented: $showQR) {
            QRSheet(user: auth.currentUser)
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            Button { showQR = true } label: {
                Image(systemName: "qrcode")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .glassEffect(.regular.interactive(), in: Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            Button("Изменить") { showEdit = true }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 18).padding(.vertical, 10)
                .glassEffect(.regular.interactive(), in: Capsule())
        }
        .padding(.horizontal, 20).padding(.top, 14)
    }

    // MARK: - Avatar + name + username

    private var avatarSection: some View {
        VStack(spacing: 10) {
            avatarCircle
                .frame(width: 90, height: 90)

            Text(auth.currentUser?.displayName ?? "Гость")
                .font(.custom("DelaGothicOne-Regular", size: 22))
                .foregroundStyle(.white)

            Text("@" + (auth.currentUser?.username ?? "crate_user"))
                .font(.subheadline)
                .foregroundStyle(CrateColor.secondaryText)

            if let bio = auth.currentUser?.bio, !bio.isEmpty {
                Text(bio)
                    .font(.footnote)
                    .foregroundStyle(CrateColor.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
        .padding(.bottom, 28)
    }

    @ViewBuilder
    private var avatarCircle: some View {
        ZStack {
            if let data = auth.currentUser?.avatarData, let img = UIImage(data: data) {
                Image(uiImage: img)
                    .resizable().scaledToFill()
                    .clipShape(Circle())
            } else {
                Circle().fill(LinearGradient(
                    colors: [Color(red:0.22,green:0.55,blue:1.0), Color(red:0.05,green:0.28,blue:0.92)],
                    startPoint: .topLeading, endPoint: .bottomTrailing))
                Text(String((auth.currentUser?.displayName ?? "G").prefix(1)).uppercased())
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .clipShape(Circle())
        .overlay(Circle().strokeBorder(Color.white.opacity(0.15), lineWidth: 2))
    }

    // MARK: - Menu

    private var menuSection: some View {
        VStack(spacing: 1) {
            menuRow(icon: "person.fill",    bg: .blue,   title: "Мой профиль",         value: nil) {}
            menuRow(icon: "star.fill",      bg: .orange, title: "Подписка",             value: "Базовый") {}
            menuRow(icon: "ticket.fill",    bg: .green,  title: "Ввести промокод",      value: nil) {}
            menuRow(icon: "megaphone.fill", bg: .yellow, title: "Канал",                value: "Добавить") {}
        }
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 20)
    }

    private func menuRow(icon: String, bg: Color, title: String, value: String?, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(bg)
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 15))
                        .foregroundStyle(.white)
                }
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
                Spacer()
                if let v = value {
                    Text(v).font(.system(size: 13)).foregroundStyle(CrateColor.secondaryText)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(CrateColor.secondaryText)
            }
            .padding(.horizontal, 16).padding(.vertical, 13)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Sign out

    private var signOutSection: some View {
        Group {
            if auth.currentUser != nil {
                Button {
                    Task { auth.signOut() }
                } label: {
                    Text("Выйти")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20).padding(.top, 24)
            }
        }
    }
}

// MARK: - Edit Profile Sheet (Telegram-стиль)

struct EditProfileSheet: View {
    @EnvironmentObject private var auth: AuthenticationManager
    @Environment(\.dismiss) private var dismiss

    @State private var name: String     = ""
    @State private var username: String = ""
    @State private var bio: String      = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var avatarImage: UIImage? = nil
    @State private var showPicker = false
    @State private var pickerType: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            LinearGradient(colors: [Color(red:0.06,green:0.04,blue:0.14), Color.black],
                           startPoint: .top, endPoint: .bottom).ignoresSafeArea()

            VStack(spacing: 0) {
                // Header bar
                HStack {
                    Button("Отмена") { dismiss() }
                        .font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .glassEffect(.regular.interactive(), in: Capsule())
                    Spacer()
                    Button("Готово") { save() }
                        .font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .glassEffect(.regular.interactive(), in: Capsule())
                }
                .padding(.horizontal, 20).padding(.top, 20)

                // Camera circle
                Button { showPicker = true } label: {
                    ZStack {
                        Circle()
                            .fill(Color(white: 0.15))
                            .frame(width: 88, height: 88)
                        if let img = avatarImage {
                            Image(uiImage: img).resizable().scaledToFill()
                                .clipShape(Circle()).frame(width: 88, height: 88)
                        } else if let data = auth.currentUser?.avatarData, let img = UIImage(data: data) {
                            Image(uiImage: img).resizable().scaledToFill()
                                .clipShape(Circle()).frame(width: 88, height: 88)
                        } else {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 28)).foregroundStyle(.white)
                        }
                    }
                }
                .buttonStyle(.plain)
                .padding(.top, 24)

                Text("Выбрать фотографию")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.top, 10)

                // Fields
                VStack(spacing: 0) {
                    profileField(placeholder: "Имя", text: $name)
                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 16)
                    profileField(placeholder: "О себе", text: $bio)
                }
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 20).padding(.top, 24)

                // Username row
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8).fill(Color(red:0.4,green:0.2,blue:0.9))
                                .frame(width: 32, height: 32)
                            Image(systemName: "at").font(.system(size: 15, weight: .bold)).foregroundStyle(.white)
                        }
                        TextField("Имя пользователя", text: $username)
                            .textFieldStyle(.plain).foregroundStyle(.white).tint(.white)
                            .autocapitalization(.none).autocorrectionDisabled()
                        Spacer()
                    }
                    .padding(.horizontal, 16).padding(.vertical, 14)
                }
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 20).padding(.top, 10)

                Spacer()
            }
        }
        .onAppear { loadCurrentValues() }
        .confirmationDialog("Выбрать фото", isPresented: $showPicker, titleVisibility: .visible) {
            Button("Камера") { pickerType = .camera; showPicker = false }
            Button("Галерея") { pickerType = .photoLibrary; showPicker = false }
            Button("Отмена", role: .cancel) {}
        }
        .sheet(isPresented: .init(
            get: { false },
            set: { _ in }
        )) {}
        .fullScreenCover(isPresented: Binding(
            get: { false },
            set: { _ in }
        )) {}
        .photosPicker(isPresented: Binding(
            get: { showPicker && pickerType == .photoLibrary },
            set: { if !$0 { showPicker = false } }
        ), selection: $selectedItem, matching: .images)
        .onChange(of: selectedItem) { _, item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self),
                   let img = UIImage(data: data) {
                    avatarImage = img
                }
            }
        }
    }

    private func profileField(placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .textFieldStyle(.plain)
            .foregroundStyle(.white).tint(.white)
            .padding(.horizontal, 16).padding(.vertical, 14)
    }

    private func loadCurrentValues() {
        name     = auth.currentUser?.displayName ?? ""
        username = auth.currentUser?.username ?? ""
        bio      = auth.currentUser?.bio ?? ""
    }

    private func save() {
        let avatarData = avatarImage.flatMap { $0.jpegData(compressionQuality: 0.8) }
        auth.updateProfile(
            displayName: name.trimmingCharacters(in: .whitespaces),
            username: username.trimmingCharacters(in: .whitespaces),
            bio: bio.trimmingCharacters(in: .whitespaces),
            avatarData: avatarData
        )
        dismiss()
    }
}

// MARK: - QR Sheet

private struct QRSheet: View {
    let user: User?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            LinearGradient(colors: [Color(red:0.06,green:0.04,blue:0.16), Color.black],
                           startPoint: .top, endPoint: .bottom).ignoresSafeArea()

            VStack(spacing: 24) {
                HStack {
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                            .frame(width: 34, height: 34)
                            .glassEffect(.regular.interactive(), in: Circle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20).padding(.top, 16)

                Spacer()

                VStack(spacing: 20) {
                    // Logo
                    CrateLogoIcon(size: 56)

                    // QR code card
                    ZStack {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.white)
                            .frame(width: 260, height: 260)
                        if let qrImage = generateQR(from: "crate://profile/\(user?.id ?? "guest")") {
                            Image(uiImage: qrImage)
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 220, height: 220)
                        }
                    }
                    .shadow(color: .white.opacity(0.08), radius: 24, y: 8)

                    VStack(spacing: 6) {
                        Text(user?.displayName ?? "Гость")
                            .font(.custom("DelaGothicOne-Regular", size: 20))
                            .foregroundStyle(.white)
                        Text("@" + (user?.username ?? "crate_user"))
                            .font(.subheadline).foregroundStyle(CrateColor.secondaryText)
                    }
                }

                Spacer()
            }
        }
    }
}
