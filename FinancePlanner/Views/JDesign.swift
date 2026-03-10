import SwiftUI

struct JColor {
    static let primary = Color(hex: "#5B2EFF")
    static let primarySoft = Color(hex: "#EDE8FF")

    static let paid = Color(hex: "#00C897")
    static let paidSoft = Color(hex: "#E0FAF4")

    static let overdue = Color(hex: "#FF6B6B")
    static let overdueSoft = Color(hex: "#FFE8E8")

    static let upcoming = Color(hex: "#FFB830")
    static let upcomingSoft = Color(hex: "#FFF4DC")

    static let daily = Color(hex: "#00BFFF")
    static let dailySoft = Color(hex: "#DCF5FF")

    static let bg = Color(hex: "#F4F6FF")
    static let card = Color.white
    static let text = Color(hex: "#1A1A2E")
    static let sub = Color(hex: "#8B8FA8")
    static let border = Color(hex: "#EDEEF5")
}

struct JCategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color

    static let all: [JCategory] = [
        .init(name: "Food", icon: "🍔", color: .init(hex: "#FF6B6B")),
        .init(name: "Transport", icon: "🚗", color: .init(hex: "#00BFFF")),
        .init(name: "Shopping", icon: "🛍️", color: .init(hex: "#FFB830")),
        .init(name: "Health", icon: "💊", color: .init(hex: "#00C897")),
        .init(name: "Bills", icon: "📄", color: .init(hex: "#5B2EFF")),
        .init(name: "Entertainment", icon: "🎮", color: .init(hex: "#FF9F43")),
        .init(name: "Other", icon: "📦", color: .init(hex: "#8B8FA8"))
    ]
}

struct JCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        content
            .background(JColor.card)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: JColor.primary.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}

struct JTag: View {
    let label: String
    let fg: Color
    let bg: Color

    var body: some View {
        Text(label)
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundColor(fg)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(bg)
            .clipShape(Capsule())
    }
}

struct JPill: View {
    let label: String
    let active: Bool
    let color: Color

    var body: some View {
        Text(label)
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundColor(active ? .white : JColor.sub)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(active ? color : JColor.card)
            .clipShape(Capsule())
            .shadow(color: active ? color.opacity(0.35) : Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
