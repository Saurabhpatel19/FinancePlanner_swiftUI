import SwiftUI

struct ThemeColors {
    private static var isDarkModeEnabled: Bool { ThemeStore.shared.isDarkMode }

    // MARK: - Core surfaces
    static var backgroundTop: Color {
        isDarkModeEnabled
        ? Color(red: 0.08, green: 0.10, blue: 0.15)
        : Color.white
    }

    static var backgroundBottom: Color {
        isDarkModeEnabled
        ? Color(red: 0.04, green: 0.06, blue: 0.10)
        : Color.white
    }

    static var cardBackground: Color {
        isDarkModeEnabled
        ? Color(red: 0.13, green: 0.16, blue: 0.23).opacity(0.88)
        : Color(red: 0.97, green: 0.98, blue: 1.0).opacity(0.9)
    }

    static var cardElevated: Color {
        isDarkModeEnabled
        ? Color(red: 0.16, green: 0.20, blue: 0.29).opacity(0.96)
        : Color(red: 0.95, green: 0.98, blue: 1.0).opacity(0.98)
    }

    static var cardBorder: Color {
        isDarkModeEnabled
        ? Color.white.opacity(0.10)
        : Color(red: 0.31, green: 0.42, blue: 0.56).opacity(0.18)
    }

    static var textPrimary: Color {
        isDarkModeEnabled ? Color(red: 0.91, green: 0.94, blue: 0.99) : Color(red: 0.11, green: 0.15, blue: 0.24)
    }

    static var textSecondary: Color {
        isDarkModeEnabled ? Color(red: 0.66, green: 0.72, blue: 0.84) : Color(red: 0.32, green: 0.39, blue: 0.51)
    }

    static var textTertiary: Color {
        isDarkModeEnabled ? Color(red: 0.53, green: 0.60, blue: 0.74) : Color(red: 0.46, green: 0.53, blue: 0.65)
    }

    static let textWhite = Color.white

    // MARK: - Accent and status
    static var accent: Color { ThemeStore.shared.accentColor }
    static var accentTeal: Color { ThemeStore.shared.accentColor.opacity(0.65) }

    static let positive = Color(red: 0.08, green: 0.66, blue: 0.39)
    static let negative = Color(red: 0.88, green: 0.31, blue: 0.25)

    // MARK: - Utility
    static var buttonBackground: Color {
        isDarkModeEnabled ? Color.white.opacity(0.08) : Color.white.opacity(0.7)
    }
    static var buttonBorder: Color { cardBorder }
    static var buttonHover: Color {
        isDarkModeEnabled ? Color.white.opacity(0.14) : Color.white.opacity(0.9)
    }
}

struct ThemeGradients {
    static var appBackground: LinearGradient {
        LinearGradient(
            colors: [
                ThemeColors.backgroundTop,
                ThemeColors.backgroundBottom
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [
                ThemeColors.accent,
                ThemeColors.accent.opacity(0.62)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var positiveGradient: LinearGradient {
        LinearGradient(
            colors: [
                ThemeColors.positive,
                ThemeColors.positive.opacity(0.75)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

struct AppBackground: View {
    var body: some View {
        ZStack {
            ThemeGradients.appBackground
            Circle()
                .fill(ThemeColors.accent.opacity(0.22))
                .frame(width: 320, height: 320)
                .blur(radius: 60)
                .offset(x: 140, y: -260)
            Circle()
                .fill(ThemeColors.accent.opacity(0.12))
                .frame(width: 280, height: 280)
                .blur(radius: 55)
                .offset(x: -120, y: 280)
            Circle()
                .fill(ThemeColors.accent.opacity(0.10))
                .frame(width: 240, height: 240)
                .blur(radius: 45)
                .offset(x: -160, y: -220)
        }
        .ignoresSafeArea()
    }
}

private struct ModernCardModifier: ViewModifier {
    var radius: CGFloat = 18

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(ThemeColors.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(ThemeColors.cardBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 18, x: 0, y: 8)
    }
}

extension View {
    func modernCard(radius: CGFloat = 18) -> some View {
        modifier(ModernCardModifier(radius: radius))
    }
}
