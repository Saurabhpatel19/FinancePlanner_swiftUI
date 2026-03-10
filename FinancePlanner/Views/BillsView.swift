import SwiftUI
import SwiftData

struct BillsView: View {
    enum BillsTab: String, CaseIterable, Identifiable {
        case monthly
        case yearly

        var id: Self { self }
    }

    @Environment(\.modelContext) private var context
    @Query private var expenses: [ExpenseModel]

    @State private var tab: BillsTab = .monthly
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedYear = Calendar.current.component(.year, from: Date())

    private var monthExpenses: [ExpenseModel] {
        expenses
            .filter {
                $0.frequency != .daily &&
                $0.frequency != .yearly &&
                $0.month == selectedMonth &&
                $0.year == selectedYear
            }
            .sorted { ($0.dueDay ?? 99, $0.name) < ($1.dueDay ?? 99, $1.name) }
    }

    private var yearExpenses: [ExpenseModel] {
        expenses
            .filter {
                $0.frequency == .yearly &&
                $0.year == selectedYear
            }
            .sorted { ($0.month, $0.dueDay ?? 99, $0.name) < ($1.month, $1.dueDay ?? 99, $1.name) }
    }

    private var totalMonth: Double { monthExpenses.reduce(0) { $0 + $1.amount } }
    private var paidMonth: Double { monthExpenses.filter(\.isPaid).reduce(0) { $0 + $1.amount } }

    private var totalYear: Double { yearExpenses.reduce(0) { $0 + $1.amount } }
    private var paidYear: Double { yearExpenses.filter(\.isPaid).reduce(0) { $0 + $1.amount } }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header

                VStack(spacing: 14) {
                    if tab == .monthly {
                        monthChips
                        monthlySummary
                        monthlyList
                    } else {
                        yearChips
                        yearlySummary
                        yearlyList
                    }
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
            Text("Bills & Commitments")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 0) {
                topTabButton(.monthly, icon: "📅", title: "Monthly")
                topTabButton(.yearly, icon: "📆", title: "Yearly")
            }
            .padding(4)
            .background(Color.white.opacity(0.16))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(.horizontal, 20)
        .padding(.top, 52)
        .padding(.bottom, 22)
        .background(
            LinearGradient(colors: [JColor.primary, Color(hex: "#9B59B6")], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
    }

    private func topTabButton(_ value: BillsTab, icon: String, title: String) -> some View {
        Button {
            tab = value
        } label: {
            Text("\(icon) \(title)")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundColor(tab == value ? JColor.primary : Color.white.opacity(0.85))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(tab == value ? Color.white : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var monthChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(1...12, id: \.self) { m in
                    JPill(label: "\(shortMonth(m)) \(String(selectedYear).suffix(2))", active: m == selectedMonth, color: JColor.primary)
                        .onTapGesture { selectedMonth = m }
                }
            }
            .padding(.vertical, 2)
        }
    }

    private var yearChips: some View {
        HStack(spacing: 10) {
            ForEach(yearRange, id: \.self) { year in
                JPill(label: String(year), active: year == selectedYear, color: JColor.primary)
                    .onTapGesture { selectedYear = year }
            }
            Spacer()
        }
    }

    private var monthlySummary: some View {
        JCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(monthTitle(selectedMonth)) \(selectedYear)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(JColor.sub)
                        Text("₹\(Int(totalMonth).formatted(.number.grouping(.automatic)))")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(JColor.text)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Fixed")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(JColor.sub)
                        Text("₹\(Int(monthExpenses.filter({ $0.type == .fixed }).reduce(0) { $0 + $1.amount }).formatted(.number.grouping(.automatic)))")
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundColor(JColor.primary)
                    }
                }

                progressBar(value: paidMonth, total: totalMonth)

                HStack {
                    Text("✓ ₹\(Int(paidMonth).formatted(.number.grouping(.automatic))) paid")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(JColor.paid)
                    Spacer()
                    Text("₹\(Int(max(0, totalMonth - paidMonth)).formatted(.number.grouping(.automatic))) left")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(JColor.sub)
                }
            }
            .padding(18)
        }
    }

    private var yearlySummary: some View {
        JCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("YEAR \(selectedYear) · \(yearExpenses.filter { !$0.isPaid }.count) unpaid")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(JColor.sub)

                Text("₹\(Int(totalYear).formatted(.number.grouping(.automatic)))")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(JColor.text)

                progressBar(value: paidYear, total: totalYear)

                HStack {
                    Text("✓ ₹\(Int(paidYear).formatted(.number.grouping(.automatic))) paid")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(JColor.paid)
                    Spacer()
                    Text("₹\(Int(max(0, totalYear - paidYear)).formatted(.number.grouping(.automatic))) remaining")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(JColor.sub)
                }
            }
            .padding(18)
        }
    }

    private var monthlyList: some View {
        VStack(spacing: 8) {
            if monthExpenses.isEmpty {
                emptyCard("No monthly bills")
            } else {
                ForEach(monthExpenses) { bill in
                    billRow(bill, yearly: false)
                }
            }
        }
    }

    private var yearlyList: some View {
        VStack(spacing: 8) {
            if yearExpenses.isEmpty {
                emptyCard("No yearly bills")
            } else {
                ForEach(yearExpenses) { bill in
                    billRow(bill, yearly: true)
                }
            }
        }
    }

    private func billRow(_ bill: ExpenseModel, yearly: Bool) -> some View {
        JCard {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Button {
                        bill.togglePaid()
                        try? context.save()
                    } label: {
                        Circle()
                            .fill(bill.isPaid ? JColor.paid : Color.white)
                            .frame(width: 28, height: 28)
                            .overlay(Circle().stroke(bill.isPaid ? JColor.paid : JColor.border, lineWidth: 2.5))
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .black))
                                    .foregroundColor(.white)
                                    .opacity(bill.isPaid ? 1 : 0)
                            )
                            .shadow(color: bill.isPaid ? JColor.paid.opacity(0.35) : .clear, radius: 0, x: 0, y: 0)
                    }
                    .buttonStyle(.plain)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(bill.name)
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundColor(JColor.text)
                            .strikethrough(bill.isPaid)

                        HStack(spacing: 6) {
                            JTag(label: yearly ? "Yearly" : "Monthly", fg: yearly ? JColor.upcoming : JColor.primary, bg: yearly ? JColor.upcomingSoft : JColor.primarySoft)
                            JTag(label: bill.type.displayTitle, fg: bill.type == .fixed ? JColor.primary : JColor.daily, bg: bill.type == .fixed ? JColor.primarySoft : JColor.dailySoft)
                            Text(dueLabel(for: bill, yearly: yearly))
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundColor(JColor.sub)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("₹\(Int(bill.amount).formatted(.number.grouping(.automatic)))")
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundColor(JColor.text)
                        if bill.isPaid {
                            Text("Paid ✓")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(JColor.paid)
                        }
                    }
                }
                .padding(14)
            }
        }
    }

    private func progressBar(value: Double, total: Double) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(JColor.border)
                Capsule()
                    .fill(LinearGradient(colors: [JColor.paid, Color(hex: "#00E5B0")], startPoint: .leading, endPoint: .trailing))
                    .frame(width: geo.size.width * CGFloat(total == 0 ? 0 : min(1, value / total)))
            }
        }
        .frame(height: 8)
    }

    private func emptyCard(_ title: String) -> some View {
        JCard {
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(JColor.sub)
                .frame(maxWidth: .infinity)
                .padding(20)
        }
    }

    private var yearRange: [Int] {
        let current = Calendar.current.component(.year, from: Date())
        return [current, current + 1, current + 2]
    }

    private func shortMonth(_ month: Int) -> String {
        DateFormatter().shortMonthSymbols[month - 1]
    }

    private func monthTitle(_ month: Int) -> String {
        DateFormatter().monthSymbols[month - 1].uppercased()
    }

    private func dueLabel(for expense: ExpenseModel, yearly: Bool) -> String {
        let day = expense.dueDay ?? expense.day ?? 1
        let month = shortMonth(expense.month)
        return yearly ? "Due \(day) \(month)" : "Due \(day) \(shortMonth(selectedMonth))"
    }
}
