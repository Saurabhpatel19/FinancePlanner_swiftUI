import SwiftUI

struct PurpleGradientCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(ThemeGradients.accentGradient)
            )
            .shadow(color: ThemeColors.accent.opacity(0.25), radius: 10, x: 0, y: 6)
    }
}
