import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var themeStore: ThemeStore

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header

                VStack(spacing: 14) {
                    nameCard
                    darkModeCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 110)
            }
        }
        .background(JColor.bg)
        .ignoresSafeArea(.container, edges: .top)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Settings")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text("Profile and appearance")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 52)
        .padding(.bottom, 24)
        .background(LinearGradient(colors: [JColor.primary, Color(hex: "#9B59B6")], startPoint: .topLeading, endPoint: .bottomTrailing))
    }

    private var nameCard: some View {
        JCard {
            VStack(alignment: .leading, spacing: 8) {
            Text("Name")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundColor(JColor.text)

            TextField("Your name", text: $themeStore.userName)
                .textInputAutocapitalization(.words)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                    .background(JColor.bg)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .padding(16)
        }
    }

    private var darkModeCard: some View {
        JCard {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                Text("Dark Mode")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(JColor.text)
                Text("Turn on dark appearance")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(JColor.sub)
                }

            Spacer()

            Toggle("", isOn: $themeStore.isDarkMode)
                .labelsHidden()
                    .tint(JColor.primary)
            }
            .padding(16)
        }
    }
}
