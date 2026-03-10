import SwiftUI
import SwiftData

struct StatsView: View {
    enum Period: String, CaseIterable, Identifiable {
        case week
        case month
        case year

        var id: Self { self }
    }

    @Query private var expenses: [ExpenseModel]

    @State private var period: Period = .month
    @State private var offset: Int = 0

    private var periodData: [(label: String, value: Double)] {
        let cal = Calendar.current
        let now = Date()

        switch period {
        case .week:
            let weekStart = cal.date(byAdding: .weekOfYear, value: -offset, to: now) ?? now
            return Array((0..<7).compactMap { idx in
                guard let day = cal.date(byAdding: .day, value: -idx, to: weekStart) else { return nil }
                let comps = cal.dateComponents([.day, .month, .year], from: day)
                let total = expenses
                    .filter {
                        $0.day == comps.day &&
                        $0.month == comps.month &&
                        $0.year == comps.year
                    }
                    .reduce(0) { $0 + $1.amount }
                return (cal.shortWeekdaySymbols[cal.component(.weekday, from: day) - 1], total)
            }.reversed())

        case .month:
            return Array((0..<6).compactMap { idx in
                let shift = idx + offset
                guard let monthDate = cal.date(byAdding: .month, value: -shift, to: now) else { return nil }
                let comps = cal.dateComponents([.month, .year], from: monthDate)
                let total = expenses
                    .filter {
                        $0.month == comps.month &&
                        $0.year == comps.year &&
                        $0.frequency != .daily
                    }
                    .reduce(0) { $0 + $1.amount }
                let label = DateFormatter().shortMonthSymbols[(comps.month ?? 1) - 1]
                return (label, total)
            }.reversed())

        case .year:
            let currentYear = cal.component(.year, from: now)
            return Array((0..<6).map { idx in
                let year = currentYear - idx - offset
                let total = expenses
                    .filter { $0.year == year }
                    .reduce(0) { $0 + $1.amount }
                return (String(year), total)
            }.reversed())
        }
    }

    private var totalSpent: Double { periodData.reduce(0) { $0 + $1.value } }
    private var dailyAverage: Double {
        let denom: Double
        switch period {
        case .week: denom = 7
        case .month: denom = 30
        case .year: denom = 365
        }
        return totalSpent / max(denom, 1)
    }

    private var categoryTotals: [(category: ExpenseCategory, amount: Double)] {
        let grouped = Dictionary(grouping: expenses, by: { $0.category ?? .other })
        return grouped
            .map { key, value in (category: key, amount: value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.amount > $1.amount }
            .prefix(6)
            .map { $0 }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header

                VStack(spacing: 14) {
                    periodNavigator
                    summaryCards
                    barsCard
                    categoryCard
                    commitmentCard
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
        VStack(spacing: 16) {
            Text("Analysis")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 0) {
                ForEach(Period.allCases) { p in
                    Button {
                        period = p
                        offset = 0
                    } label: {
                        Text(p.rawValue.capitalized)
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundColor(period == p ? JColor.overdue : Color.white.opacity(0.85))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 9)
                            .background(period == p ? Color.white : .clear)
                            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(4)
            .background(Color.white.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(.horizontal, 20)
        .padding(.top, 52)
        .padding(.bottom, 22)
        .background(LinearGradient(colors: [JColor.overdue, Color(hex: "#FF9F43")], startPoint: .topLeading, endPoint: .bottomTrailing))
    }

    private var periodNavigator: some View {
        JCard {
            HStack {
                Button {
                    offset += 1
                } label: {
                    navArrow("chevron.left", enabled: true)
                }
                .buttonStyle(.plain)

                Spacer()

                VStack(spacing: 2) {
                    Text(periodLabel)
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundColor(JColor.text)
                    if offset > 0 {
                        Text("tap › for newer")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(JColor.sub)
                    }
                }

                Spacer()

                Button {
                    offset = max(0, offset - 1)
                } label: {
                    navArrow("chevron.right", enabled: offset > 0)
                }
                .disabled(offset == 0)
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    private func navArrow(_ icon: String, enabled: Bool) -> some View {
        Circle()
            .fill(enabled ? JColor.bg : JColor.border)
            .frame(width: 36, height: 36)
            .overlay(Circle().stroke(JColor.border, lineWidth: 1.5))
            .overlay(Image(systemName: icon).font(.system(size: 14, weight: .bold)).foregroundColor(enabled ? JColor.sub : Color.gray.opacity(0.7)))
    }

    private var summaryCards: some View {
        HStack(spacing: 10) {
            summaryCard("Total Spent", value: "₹\(Int(totalSpent).formatted(.number.grouping(.automatic)))", color: JColor.overdue)
            summaryCard("Daily Avg", value: "₹\(Int(dailyAverage).formatted(.number.grouping(.automatic)))", color: JColor.daily)
            summaryCard("Entries", value: "\(expenses.count)", color: JColor.upcoming)
        }
    }

    private func summaryCard(_ title: String, value: String, color: Color) -> some View {
        JCard {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(JColor.sub)
                Text(value)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundColor(color)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 10)
        }
    }

    private var barsCard: some View {
        JCard {
            VStack(alignment: .leading, spacing: 16) {
                Text(chartTitle)
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundColor(JColor.text)

                let maxValue = max(periodData.map(\.value).max() ?? 1, 1)

                HStack(alignment: .bottom, spacing: 6) {
                    ForEach(Array(periodData.enumerated()), id: \.offset) { idx, item in
                        let isLast = idx == periodData.count - 1
                        VStack(spacing: 4) {
                            Text(isLast ? shortAmount(item.value) : "")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundColor(isLast ? JColor.overdue : .clear)
                                .frame(height: 12)

                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(
                                    isLast
                                    ? LinearGradient(colors: [JColor.overdue, Color(hex: "#FF9F43")], startPoint: .top, endPoint: .bottom)
                                    : LinearGradient(colors: [JColor.primarySoft, JColor.border], startPoint: .top, endPoint: .bottom)
                                )
                                .frame(width: 32, height: max(8, CGFloat(item.value / maxValue) * 110))

                            Text(item.label)
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(isLast ? JColor.overdue : JColor.sub)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 130, alignment: .bottom)
            }
            .padding(16)
        }
    }

    private var categoryCard: some View {
        JCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("By Category")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundColor(JColor.text)

                ForEach(Array(categoryTotals.enumerated()), id: \.offset) { _, item in
                    let total = max(totalSpent, 1)
                    let pct = max(2, (item.amount / total) * 100)
                    let color = colorForCategory(item.category)

                    VStack(spacing: 5) {
                        HStack {
                            HStack(spacing: 8) {
                                Image(systemName: item.category.systemImage)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(color)
                                Text(item.category.displayTitle)
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(JColor.text)
                            }
                            Spacer()
                            Text("₹\(Int(item.amount).formatted(.number.grouping(.automatic)))")
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundColor(color)
                            Text("\(Int(pct))%")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(JColor.sub)
                        }

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(JColor.border)
                                Capsule().fill(color).frame(width: geo.size.width * CGFloat(min(pct / 100, 1)))
                            }
                        }
                        .frame(height: 7)
                    }
                }
            }
            .padding(16)
        }
    }

    private var commitmentCard: some View {
        let recurring = expenses.filter { $0.frequency == .monthly || $0.frequency == .yearly }.reduce(0) { $0 + $1.amount }
        let daily = expenses.filter { $0.frequency == .daily }.reduce(0) { $0 + $1.amount }
        let total = max(recurring + daily, 1)

        return JCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Committed vs Discretionary")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundColor(JColor.text)

                HStack(spacing: 12) {
                    splitCard(
                        title: "Committed Bills",
                        value: recurring,
                        subtitle: "Monthly + Yearly",
                        color: JColor.primary,
                        pct: recurring / total
                    )
                    splitCard(
                        title: "Daily Spending",
                        value: daily,
                        subtitle: "Discretionary",
                        color: JColor.daily,
                        pct: daily / total
                    )
                }
            }
            .padding(16)
        }
    }

    private func splitCard(title: String, value: Double, subtitle: String, color: Color, pct: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(JColor.sub)
            Text("₹\(Int(value).formatted(.number.grouping(.automatic)))")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(color)
            Text(subtitle)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(JColor.sub)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.black.opacity(0.08))
                    Capsule().fill(color).frame(width: geo.size.width * CGFloat(min(max(pct, 0), 1)))
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(color.opacity(0.12))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(color.opacity(0.3), lineWidth: 1.5))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .frame(maxWidth: .infinity)
    }

    private var chartTitle: String {
        switch period {
        case .week: return "Daily Breakdown"
        case .month: return "6-Month Trend"
        case .year: return "Year on Year"
        }
    }

    private var periodLabel: String {
        switch period {
        case .week:
            return offset == 0 ? "This Week" : offset == 1 ? "Last Week" : "\(offset) Weeks Ago"
        case .month:
            let target = Calendar.current.date(byAdding: .month, value: -offset, to: Date()) ?? Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: target)
        case .year:
            let year = Calendar.current.component(.year, from: Date()) - offset
            return String(year)
        }
    }

    private func shortAmount(_ value: Double) -> String {
        if value >= 1000 {
            return "₹\(Int((value / 1000).rounded()))k"
        }
        return "₹\(Int(value))"
    }

    private func colorForCategory(_ category: ExpenseCategory) -> Color {
        switch category {
        case .groceries: return Color(hex: "#FF6B6B")
        case .utilities, .subscriptions, .insurance, .emi: return JColor.primary
        case .shopping: return Color(hex: "#FFB830")
        case .transport: return JColor.daily
        case .health: return JColor.paid
        case .entertainment: return Color(hex: "#FF9F43")
        default: return JColor.sub
        }
    }
}
