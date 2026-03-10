import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    let onStart: () -> Void

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 24) {
                Spacer(minLength: 24)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Take Control")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundColor(ThemeColors.textPrimary)
                    Text("Plan recurring and one-time expenses with clear monthly and yearly visibility.")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(ThemeColors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
                .modernCard(radius: 26)

                VStack(alignment: .leading, spacing: 12) {
                    feature("calendar.badge.clock", "Recurring planning")
                    feature("chart.bar.xaxis", "Monthly and yearly snapshots")
                    feature("checkmark.circle", "Payment tracking")
                }
                .padding(20)
                .modernCard(radius: 20)

                Spacer()

                Button {
                    hasSeenOnboarding = true
                    onStart()
                } label: {
                    Text("Start Planning")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(ThemeGradients.accentGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                Button("Skip for now") {
                    hasSeenOnboarding = true
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(ThemeColors.textSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
    }

    private func feature(_ icon: String, _ title: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(ThemeColors.accent)
                .frame(width: 24, height: 24)
                .background(ThemeColors.accent.opacity(0.14))
                .clipShape(Circle())
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(ThemeColors.textPrimary)
            Spacer()
        }
    }
}
