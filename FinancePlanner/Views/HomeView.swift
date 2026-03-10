import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var expenses: [ExpenseModel]

    var onGoToBills: (() -> Void)? = nil
    var onGoToDaily: (() -> Void)? = nil

    private var now: Date { Date() }

    private var monthKey: (month: Int, year: Int) {
        let cal = Calendar.current
        return (cal.component(.month, from: now), cal.component(.year, from: now))
    }

    private var todayKey: (day: Int, month: Int, year: Int) {
        let cal = Calendar.current
        return (
            cal.component(.day, from: now),
            cal.component(.month, from: now),
            cal.component(.year, from: now)
        )
    }

    private var todayDaily: [ExpenseModel] {
        expenses
            .filter {
                $0.frequency == .daily &&
                $0.day == todayKey.day &&
                $0.month == todayKey.month &&
                $0.year == todayKey.year
            }
            .sorted { $0.name < $1.name }
    }

    private var monthlyBills: [ExpenseModel] {
        expenses
            .filter {
                $0.frequency != .daily &&
                $0.month == monthKey.month &&
                $0.year == monthKey.year
            }
            .sorted { $0.name < $1.name }
    }

    private var totalDaily: Double { todayDaily.reduce(0) { $0 + $1.amount } }
    private var totalMonthly: Double { monthlyBills.reduce(0) { $0 + $1.amount } }
    private var paidMonthly: Double { monthlyBills.filter(\.isPaid).reduce(0) { $0 + $1.amount } }
    private var unpaidMonthly: [ExpenseModel] { monthlyBills.filter { !$0.isPaid } }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header
                content
            }
            .padding(.bottom, 110)
        }
        .background(JColor.bg)
        .ignoresSafeArea(.container, edges: .top)
    }

    private var header: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Good morning")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(JColor.sub)
                    Text(ThemeStore.shared.userName.isEmpty ? "Saurabh" : ThemeStore.shared.userName)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(JColor.text)
                    Text(formattedDate(now))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(JColor.sub)
                }
                Spacer()
                Circle()
                    .fill(JColor.primarySoft)
                    .frame(width: 46, height: 46)
                    .overlay(Text("👤").font(.system(size: 20)))
            }

            HStack(spacing: 12) {
                metricCard(title: "TODAY SPENT", value: totalDaily, tint: JColor.daily, bg: JColor.dailySoft, subtitle: "\(todayKey.day) \(shortMonth(todayKey.month)) \(todayKey.year)")
                metricCard(title: "MONTHLY BILLS", value: totalMonthly, tint: JColor.primary, bg: JColor.primarySoft, subtitle: unpaidMonthly.isEmpty ? "All paid" : "\(unpaidMonthly.count) unpaid")
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 52)
        .padding(.bottom, 20)
        .background(Color.white)
        .overlay(alignment: .bottom) {
            Rectangle().fill(JColor.border).frame(height: 1)
        }
    }

    private func metricCard(title: String, value: Double, tint: Color, bg: Color, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(tint)
            Text("₹\(Int(value).formatted(.number.grouping(.automatic)))")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(JColor.text)
            Text(subtitle)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(JColor.sub)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(bg)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(tint.opacity(0.2), lineWidth: 1.2)
        )
    }

    private var content: some View {
        VStack(spacing: 16) {
            monthlyProgressCard

            sectionHeader("⏰ Upcoming Dues", action: { onGoToBills?() })
            VStack(spacing: 8) {
                ForEach(unpaidMonthly.prefix(3)) { bill in
                    upcomingRow(bill)
                }
            }

            sectionHeader("Today's Spending", action: { onGoToDaily?() })
            VStack(spacing: 8) {
                ForEach(todayDaily.prefix(4)) { item in
                    dailyRow(item)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    private var monthlyProgressCard: some View {
        JCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(monthTitle(monthKey.month)) \(monthKey.year)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(JColor.sub)
                        Text("₹\(Int(paidMonthly).formatted(.number.grouping(.automatic))) / ₹\(Int(max(totalMonthly, 0)).formatted(.number.grouping(.automatic)))")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundColor(JColor.text)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        JTag(label: unpaidMonthly.isEmpty ? "All paid" : "\(unpaidMonthly.count) unpaid", fg: unpaidMonthly.isEmpty ? JColor.paid : JColor.overdue, bg: unpaidMonthly.isEmpty ? JColor.paidSoft : JColor.overdueSoft)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(JColor.sub)
                    }
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(JColor.border)
                        Capsule()
                            .fill(LinearGradient(colors: [JColor.paid, JColor.paid.opacity(0.75)], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * CGFloat(totalMonthly == 0 ? 0 : min(1, paidMonthly / totalMonthly)))
                    }
                }
                .frame(height: 8)

                HStack {
                    Text("✓ ₹\(Int(paidMonthly).formatted(.number.grouping(.automatic))) paid")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(JColor.paid)
                    Spacer()
                    Text("₹\(Int(max(0, totalMonthly - paidMonthly)).formatted(.number.grouping(.automatic))) remaining")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(JColor.sub)
                }
            }
            .padding(18)
        }
        .onTapGesture { onGoToBills?() }
    }

    private func sectionHeader(_ title: String, action: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundColor(JColor.text)
            Spacer()
            Button(action: action) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Circle().stroke(JColor.border, lineWidth: 1.2)
                    )
                    .overlay(Image(systemName: "chevron.right").font(.system(size: 12, weight: .bold)).foregroundColor(JColor.sub))
            }
            .buttonStyle(.plain)
        }
    }

    private func upcomingRow(_ bill: ExpenseModel) -> some View {
        JCard {
            HStack(spacing: 12) {
                Rectangle()
                    .fill(JColor.overdue)
                    .frame(width: 4)
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(bill.name)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(JColor.text)
                    Text("Due: \(bill.dueDay ?? 1) \(shortMonth(monthKey.month))")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(JColor.sub)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("₹\(Int(bill.amount).formatted(.number.grouping(.automatic)))")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundColor(JColor.text)
                    JTag(label: "Upcoming", fg: JColor.upcoming, bg: JColor.upcomingSoft)
                }
            }
            .padding(14)
        }
    }

    private func dailyRow(_ item: ExpenseModel) -> some View {
        JCard {
            HStack(spacing: 12) {
                Circle()
                    .fill((colorForCategory(item.category ?? .other)).opacity(0.2))
                    .frame(width: 42, height: 42)
                    .overlay(Text(emojiForCategory(item.category ?? .other)).font(.system(size: 18)))

                VStack(alignment: .leading, spacing: 1) {
                    Text(item.name)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(JColor.text)
                    Text((item.category ?? .other).displayTitle)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(JColor.sub)
                }
                Spacer()
                Text("-₹\(Int(item.amount))")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundColor(JColor.overdue)
            }
            .padding(12)
        }
    }

    private func shortMonth(_ m: Int) -> String {
        DateFormatter().shortMonthSymbols[m - 1]
    }

    private func monthTitle(_ m: Int) -> String {
        DateFormatter().monthSymbols[m - 1].uppercased()
    }

    private func formattedDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateStyle = .full
        return fmt.string(from: date)
    }

    private func colorForCategory(_ c: ExpenseCategory) -> Color {
        switch c {
        case .groceries: return .red
        case .transport: return .blue
        case .shopping: return .orange
        case .health: return .green
        case .utilities, .subscriptions, .insurance, .emi: return JColor.primary
        case .entertainment: return .purple
        default: return .gray
        }
    }

    private func emojiForCategory(_ c: ExpenseCategory) -> String {
        switch c {
        case .groceries: return "🍔"
        case .transport: return "🚗"
        case .shopping: return "🛍️"
        case .health: return "💊"
        case .utilities, .subscriptions, .insurance, .emi: return "📄"
        case .entertainment: return "🎮"
        default: return "📦"
        }
    }
}
