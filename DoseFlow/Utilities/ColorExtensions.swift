import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

/// Predefined color options for people
struct PersonColors {
    static let options: [(name: String, hex: String)] = [
        ("Blue", "#6A9FD4"),
        ("Purple", "#9B7DB8"),
        ("Pink", "#D4728A"),
        ("Orange", "#D4A06A"),
        ("Green", "#6AB89A"),
        ("Teal", "#5AADAD"),
        ("Red", "#C85A5A"),
        ("Indigo", "#6A6AD4"),
    ]
}
