import Foundation

enum AppLocale {
    static var isRussian: Bool {
        Locale.current.language.languageCode?.identifier == "ru"
    }
}

func bi(_ ru: String, _ en: String) -> String {
    AppLocale.isRussian ? ru : en
}
