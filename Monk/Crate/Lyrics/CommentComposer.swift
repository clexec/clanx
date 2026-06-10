import SwiftUI

struct CommentComposer: View {
    @Binding var text: String
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            TextField(bi("Написать комментарий…", "Write a comment…"), text: $text)
                .textFieldStyle(.plain).foregroundStyle(.white)
                .padding(.horizontal, 18).padding(.vertical, 12)
                .crateGlass(Capsule())
            Button(action: onSend) {
                Image(systemName: "arrow.up").font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white).frame(width: 44, height: 44)
            }
            .buttonStyle(.plain).crateGlass(Circle())
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
    }
}
