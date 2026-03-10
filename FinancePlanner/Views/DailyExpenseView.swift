import SwiftUI
import SwiftData

struct DailyExpenseView: View {
    @Environment(\.modelContext) private var context
    @Query private var expenses: [ExpenseModel]

    @State private var selectedDay: Int = Calendar.current.component(.day, from: Date())
    @State private var editingExpense: ExpenseModel?

    private var currentMonth: Int { Calendar.current.component(.month, from: Date()) }
    private var currentYear: Int { Calendar.current.component(.year, from: Date()) }

    private var todayTotal: Double {
        let c = Calendar.current
        let now = Date()
        return expenses
            .filter {
                $0.frequency == .daily &&
                $0.day == c.component(.day, from: now) &&
                $0.month == c.component(.month, from: now) &&
                $0.year == c.component(.year, from: now)
            }
            .reduce(0) { $0 + $1.amount }
    }

    private var groupedDaily: [(title: String, items: [ExpenseModel])] {
        let today = Calendar.current.component(.day, from: Date())
        let yesterday = max(1, today - 1)

        let days = [selectedDay, yesterday, max(1, yesterday - 1)]
        return days.compactMap { day in
            let items = expenses
                .filter {
                    $0.frequency == .daily &&
                    $0.day == day &&
                    $0.month == currentMonth &&
                    $0.year == currentYear
                }
                .sorted { $0.name < $1.name }
            guard !items.isEmpty else { return nil }

            let title: String
            if day == today {
                title = "Today"
            } else if day == yesterday {
                title = "Yesterday"
            } else {
                title = "\(day) \(shortMonth(currentMonth))"
            }
            return (title, items)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header

                VStack(spacing: 14) {
                    dayStrip

                    ForEach(Array(groupedDaily.enumerated()), id: \.offset) { _, group in
                        section(group.title, items: group.items)
                    }

                    if groupedDaily.isEmpty {
                        JCard {
                            VStack(spacing: 8) {
                                Text("No entries")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(JColor.text)
                                Text("Tap + to add daily expense")
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundColor(JColor.sub)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(20)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 110)
            }
        }
        .background(JColor.bg)
        .ignoresSafeArea(.container, edges: .top)
        .sheet(item: $editingExpense) { expense in
            AddEditExpenseView(expense: expense, actionType: .update, context: context)
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Daily Expenses")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("\(monthName(currentMonth)) \(currentYear)")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.78))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("TODAY TOTAL")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.75))
                Text("₹\(Int(todayTotal).formatted(.number.grouping(.automatic)))")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 52)
        .padding(.bottom, 24)
        .background(LinearGradient(colors: [JColor.daily, Color(hex: "#0099CC")], startPoint: .topLeading, endPoint: .bottomTrailing))
    }

    private var dayStrip: some View {
        JCard {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(1...28, id: \.self) { day in
                        let isSelected = day == selectedDay
                        VStack(spacing: 2) {
                            Text(shortWeekday(for: day))
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundColor(isSelected ? .white.opacity(0.8) : JColor.sub)
                            Text("\(day)")
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundColor(isSelected ? .white : JColor.text)
                            Circle()
                                .fill((day >= max(1, selectedDay - 3) && day <= selectedDay) ? (isSelected ? .white.opacity(0.75) : JColor.daily) : .clear)
                                .frame(width: 5, height: 5)
                        }
                        .frame(width: 38, height: 58)
                        .background(isSelected ? JColor.daily : .clear)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .onTapGesture { selectedDay = day }
                    }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 6)
            }
        }
        .padding(.top, -16)
    }

    private func section(_ title: String, items: [ExpenseModel]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundColor(JColor.text)
                Spacer()
                Text("₹\(Int(items.reduce(0) { $0 + $1.amount }).formatted(.number.grouping(.automatic)))")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(JColor.sub)
            }

            VStack(spacing: 8) {
                ForEach(items) { item in
                    JCard {
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(colorForCategory(item.category ?? .other).opacity(0.15))
                                .frame(width: 44, height: 44)
                                .overlay(Text(emojiForCategory(item.category ?? .other)).font(.system(size: 20)))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name)
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(JColor.text)
                                Text((item.category ?? .other).displayTitle)
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundColor(JColor.sub)
                            }
                            Spacer()
                            Text("₹\(Int(item.amount).formatted(.number.grouping(.automatic)))")
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundColor(JColor.text)
                        }
                        .padding(14)
                    }
                    .onTapGesture { editingExpense = item }
                }
            }
        }
    }

    private func monthName(_ month: Int) -> String {
        DateFormatter().monthSymbols[month - 1]
    }

    private func shortMonth(_ month: Int) -> String {
        DateFormatter().shortMonthSymbols[month - 1]
    }

    private func shortWeekday(for day: Int) -> String {
        let c = Calendar.current
        let date = c.date(from: DateComponents(year: currentYear, month: currentMonth, day: day)) ?? Date()
        let idx = c.component(.weekday, from: date) - 1
        return ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"][max(0, min(6, idx))]
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
