import Foundation

enum CrateFormat {
    private static let relative: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()

    static func relativeString(_ date: Date) -> String {
        relative.localizedString(for: date, relativeTo: Date())
    }
}
