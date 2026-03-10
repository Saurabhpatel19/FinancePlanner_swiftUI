import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case daily
    case bills
    case stats
    case settings

    var id: Self { self }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .daily: return "calendar"
        case .bills: return "list.clipboard.fill"
        case .stats: return "chart.bar.fill"
        case .settings: return "gearshape.fill"
        }
    }

    var label: String {
        switch self {
        case .home: return "Home"
        case .daily: return "Daily"
        case .bills: return "Bills"
        case .stats: return "Stats"
        case .settings: return "Settings"
        }
    }
}

struct RootTabView: View {
    @State private var activeTab: AppTab = .home
    @State private var showAddModal = false

    var body: some View {
        ZStack {
            TabView(selection: $activeTab) {
                HomeView(onGoToBills: { activeTab = .bills }, onGoToDaily: { activeTab = .daily })
                    .tag(AppTab.home)
                    .tabItem {
                        Image(systemName: AppTab.home.icon)
                        Text(AppTab.home.label)
                    }

                DailyExpenseView()
                    .tag(AppTab.daily)
                    .tabItem {
                        Image(systemName: AppTab.daily.icon)
                        Text(AppTab.daily.label)
                    }

                BillsView()
                    .tag(AppTab.bills)
                    .tabItem {
                        Image(systemName: AppTab.bills.icon)
                        Text(AppTab.bills.label)
                    }

                StatsView()
                    .tag(AppTab.stats)
                    .tabItem {
                        Image(systemName: AppTab.stats.icon)
                        Text(AppTab.stats.label)
                    }

                SettingsView()
                    .tag(AppTab.settings)
                    .tabItem {
                        Image(systemName: AppTab.settings.icon)
                        Text(AppTab.settings.label)
                    }
            }
            .tint(JColor.primary)
            .ignoresSafeArea(.container, edges: [.top, .bottom])

            if showAddModal {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .onTapGesture { showAddModal = false }

                VStack {
                    Spacer()
                    AddExpenseModalView(
                        defaultTab: defaultAddTab,
                        onClose: { showAddModal = false }
                    )
                }
                .ignoresSafeArea(edges: .bottom)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    fab
                }
                .padding(.trailing, 20)
                .padding(.bottom, 76)
            }
            .allowsHitTesting(!showAddModal)
        }
        .animation(.easeInOut(duration: 0.2), value: showAddModal)
    }

    private var fab: some View {
        Button {
            showAddModal = true
        } label: {
            Circle()
                .fill(LinearGradient(colors: [JColor.primary, Color(hex: "#9B59B6")], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 58, height: 58)
                .overlay(
                    Circle()
                        .stroke(.white, lineWidth: 3)
                )
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .black))
                        .foregroundColor(.white)
                )
                .shadow(color: JColor.primary.opacity(0.55), radius: 14, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }

    private var defaultAddTab: AddExpenseModalView.AddMode {
        switch activeTab {
        case .daily: return .daily
        case .bills: return .monthly
        case .stats, .home, .settings: return .daily
        }
    }
}
