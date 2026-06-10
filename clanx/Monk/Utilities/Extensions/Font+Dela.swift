import SwiftUI

extension Font {
    private static let dela = "DelaGothicOne-Regular"

    static func dela(_ size: CGFloat) -> Font {
        .custom(dela, size: size)
    }

    // Mapped to semantic text roles — use these instead of system font where Dela is wanted
    static var delaLargeTitle: Font { .custom(dela, size: 34, relativeTo: .largeTitle) }
    static var delaTitle:      Font { .custom(dela, size: 28, relativeTo: .title) }
    static var delaTitle2:     Font { .custom(dela, size: 22, relativeTo: .title2) }
    static var delaTitle3:     Font { .custom(dela, size: 20, relativeTo: .title3) }
    static var delaHeadline:   Font { .custom(dela, size: 17, relativeTo: .headline) }
    static var delaBody:       Font { .custom(dela, size: 17, relativeTo: .body) }
    static var delaCallout:    Font { .custom(dela, size: 16, relativeTo: .callout) }
    static var delaCaption:    Font { .custom(dela, size: 12, relativeTo: .caption) }
}
