import Foundation
import SwiftUI

struct CountdownItem: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    var name: String
    var targetDate: Date
    var icon: String
    var colorHex: String
    let createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        targetDate: Date,
        icon: String = "star",
        colorHex: String = IconPalette.defaultHex,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.targetDate = targetDate
        self.icon = icon
        self.colorHex = colorHex
        self.createdAt = createdAt
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, targetDate, icon, colorHex, createdAt
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        targetDate = try values.decode(Date.self, forKey: .targetDate)
        icon = try values.decodeIfPresent(String.self, forKey: .icon) ?? "star"
        colorHex = try values.decodeIfPresent(String.self, forKey: .colorHex) ?? IconPalette.defaultHex
        createdAt = try values.decode(Date.self, forKey: .createdAt)
    }
}

/// Curated SF Symbols suitable for countdown subjects (availability-verified on macOS 27).
enum IconCatalog {
    static let symbols: [String] = [
        // Life & celebration
        "star", "heart", "sparkles", "balloon", "gift", "birthday.cake", "party.popper",
        // Time
        "alarm", "hourglass", "timer", "stopwatch", "calendar", "flag.checkered", "target",
        // Travel
        "airplane", "airplane.departure", "car", "bicycle", "bus", "ferry", "suitcase",
        "map", "mappin.and.ellipse", "globe", "umbrella",
        // Work & study
        "briefcase", "graduationcap", "book", "book.closed", "pencil", "clipboard", "doc.text", "folder",
        "building.2", "storefront", "shippingbox", "printer",
        // Tech & media
        "laptopcomputer", "desktopcomputer", "keyboard", "tv", "gamecontroller", "headphones", "mic",
        "camera", "video", "phone", "message", "envelope", "bell", "bookmark", "tag", "wifi",
        // Home & food
        "house", "bed.double", "lightbulb", "fork.knife", "cup.and.saucer", "wineglass",
        "carrot", "takeoutbag.and.cup.and.straw", "cart", "bag", "creditcard", "banknote", "key",
        // Health & sport
        "figure.run", "figure.walk", "figure.hiking", "dumbbell",
        "pills", "stethoscope", "cross.case", "syringe",
        // Nature & weather
        "leaf", "tree", "sun.max", "sunrise", "sunset", "moon", "moon.stars",
        "cloud.sun", "cloud.rain", "snowflake", "wind", "drop", "bolt",
        // Fun & objects
        "trophy", "medal", "crown", "shield", "fireworks", "ticket", "theatermasks",
        "music.note", "paintbrush", "paintpalette", "photo", "hammer", "wrench", "wrench.and.screwdriver", "pawprint"
    ]
    static let defaultSymbol = "star"

    static func sanitized(_ symbol: String) -> String {
        symbols.contains(symbol) ? symbol : defaultSymbol
    }
}

/// Curated icon colors stored as hex strings.
enum IconPalette {
    static let defaultHex = "#0A76E5"
    static let hexColors: [String] = [
        "#0A76E5", // blue (theme)
        "#5E5CE6", // indigo
        "#AF52DE", // purple
        "#FF2D92", // pink
        "#FF3B30", // red
        "#FF9500", // orange
        "#E0A800", // gold
        "#34C759", // green
        "#30B0C7", // teal
        "#8E8E93"  // gray
    ]

    static func sanitized(_ hex: String) -> String {
        hexColors.contains(hex) ? hex : defaultHex
    }

    static func color(_ hex: String) -> Color {
        sanitized(hex).color
    }
}

extension String {
    var color: Color {
        var value: UInt64 = 0
        let hex = hasPrefix("#") ? String(dropFirst()) : self
        guard hex.count == 6, Scanner(string: hex).scanHexInt64(&value) else {
            return Color(nsColor: .liteCountBlue)
        }
        return Color(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}
