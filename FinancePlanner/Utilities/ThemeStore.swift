import SwiftUI
import Combine
import UIKit

enum AccentTheme: String, CaseIterable, Identifiable {
    case ocean
    case mint
    case amber
    case rose
    case violet
    case custom

    var id: Self { self }

    var title: String {
        switch self {
        case .ocean: return "Ocean"
        case .mint: return "Mint"
        case .amber: return "Amber"
        case .rose: return "Rose"
        case .violet: return "Violet"
        case .custom: return "Custom"
        }
    }

    var primary: Color {
        switch self {
        case .ocean: return Color(red: 0.01, green: 0.44, blue: 0.78)
        case .mint: return Color(red: 0.04, green: 0.50, blue: 0.35)
        case .amber: return Color(red: 0.75, green: 0.42, blue: 0.10)
        case .rose: return Color(red: 0.72, green: 0.28, blue: 0.48)
        case .violet: return Color(red: 0.41, green: 0.29, blue: 0.72)
        case .custom: return Color(red: 0.01, green: 0.44, blue: 0.78)
        }
    }
}

final class ThemeStore: ObservableObject {
    static let shared = ThemeStore()

    @Published var userName: String {
        didSet {
            UserDefaults.standard.set(userName, forKey: "settings.user_name")
        }
    }

    @Published var selectedTheme: AccentTheme {
        didSet {
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: "settings.theme")
            refreshID = UUID()
        }
    }

    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "settings.dark_mode")
            refreshID = UUID()
        }
    }

    @Published var customRed: Double {
        didSet { UserDefaults.standard.set(customRed, forKey: "settings.custom_red") }
    }

    @Published var customGreen: Double {
        didSet { UserDefaults.standard.set(customGreen, forKey: "settings.custom_green") }
    }

    @Published var customBlue: Double {
        didSet { UserDefaults.standard.set(customBlue, forKey: "settings.custom_blue") }
    }

    @Published var refreshID = UUID()

    var accentColor: Color {
        selectedTheme == .custom ? Color(red: customRed, green: customGreen, blue: customBlue) : selectedTheme.primary
    }

    private init() {
        let defaults = UserDefaults.standard
        let name = defaults.string(forKey: "settings.user_name") ?? ""
        let themeRaw = defaults.string(forKey: "settings.theme") ?? AccentTheme.ocean.rawValue

        userName = name
        selectedTheme = AccentTheme(rawValue: themeRaw) ?? .ocean
        isDarkMode = defaults.bool(forKey: "settings.dark_mode")
        customRed = defaults.object(forKey: "settings.custom_red") as? Double ?? 0.01
        customGreen = defaults.object(forKey: "settings.custom_green") as? Double ?? 0.44
        customBlue = defaults.object(forKey: "settings.custom_blue") as? Double ?? 0.78
    }

    func applyTheme(_ theme: AccentTheme) {
        selectedTheme = theme
        refreshID = UUID()
    }

    func applyCustomColor(_ color: Color) {
        let ui = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)

        customRed = Double(r)
        customGreen = Double(g)
        customBlue = Double(b)
        selectedTheme = .custom
        refreshID = UUID()
    }
}
