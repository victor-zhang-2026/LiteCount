import AppKit
import SwiftUI

enum AppearanceMode: String, CaseIterable {
    case light
    case dark

    var colorScheme: ColorScheme {
        switch self {
        case .light: .light
        case .dark: .dark
        }
    }

    var symbolName: String {
        switch self {
        case .light: "sun.max"
        case .dark: "moon"
        }
    }
}

extension NSColor {
    static let liteCountBlue = NSColor(name: nil) { appearance in
        appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            ? NSColor(red: 40 / 255, green: 150 / 255, blue: 255 / 255, alpha: 1)
            : NSColor(red: 9 / 255, green: 118 / 255, blue: 229 / 255, alpha: 1)
    }

    static let liteCountBlueHover = NSColor(name: nil) { appearance in
        appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            ? NSColor(red: 32 / 255, green: 128 / 255, blue: 226 / 255, alpha: 1)
            : NSColor(red: 7 / 255, green: 98 / 255, blue: 190 / 255, alpha: 1)
    }
}

extension Color {
    static let liteCountBlue = Color(nsColor: .liteCountBlue)

    static let liteCountSoftBlue = Color(nsColor: NSColor(name: nil) { appearance in
        appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            ? NSColor(red: 23 / 255, green: 60 / 255, blue: 98 / 255, alpha: 1)
            : NSColor(red: 226 / 255, green: 239 / 255, blue: 252 / 255, alpha: 1)
    })

    static let liteCountElevated = Color(nsColor: .controlBackgroundColor)
    static let liteCountSeparator = Color(nsColor: .separatorColor)
    static let liteCountPrimaryText = Color(nsColor: .labelColor)
    static let liteCountSecondaryText = Color(nsColor: .secondaryLabelColor)
}
