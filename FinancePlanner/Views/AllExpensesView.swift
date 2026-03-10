import SwiftUI
import SwiftData

struct AllExpensesView: View {
    @Query(sort: [
        SortDescriptor(\ExpenseModel.year, order: .forward),
        SortDescriptor(\ExpenseModel.month, order: .forward)
    ])
    private var expenses: [ExpenseModel]

    @State private var expandedYears: Set<Int> = []

    var body: some View {
        ZStack {
            AppBackground()

            NavigationStack {
                ScrollView {
                    VStack(spacing: 14) {
                        header

                        if yearlySeriesSections.isEmpty {
                            emptyState
                        } else {
                            ForEach(yearlySeriesSections) { section in
                                yearSectionCard(section)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 28)
                }
                .navigationBarHidden(true)
                .onAppear {
                    let currentYear = Calendar.current.component(.year, from: Date())
                    expandedYears = Set(yearlySeriesSections.map(\.year).filter { $0 <= currentYear })
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("All Expenses")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(ThemeColors.textPrimary)
            Text("Complete expense history")
                .font(.subheadline)
                .foregroundColor(ThemeColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "tray")
                .font(.system(size: 30, weight: .semibold))
                .foregroundColor(ThemeColors.accent)
            Text("No expenses yet")
                .font(.headline)
                .foregroundColor(ThemeColors.textPrimary)
            Text("Start adding expenses to see your timeline")
                .font(.subheadline)
                .foregroundColor(ThemeColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .modernCard()
    }

    private func yearSectionCard(_ section: YearExpenseSection) -> some View {
        let total = section.items.reduce(0) { $0 + $1.displayTotal }
        let expanded = expandedYears.contains(section.year)

        return VStack(spacing: 0) {
            Button {
                withAnimation(.spring(duration: 0.24)) {
                    if expanded { expandedYears.remove(section.year) } else { expandedYears.insert(section.year) }
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(section.year))
                            .font(.title3.weight(.bold))
                            .foregroundColor(ThemeColors.textPrimary)
                        Text("\(section.items.count) series • ₹\(Int(total))")
                            .font(.caption)
                            .foregroundColor(ThemeColors.textSecondary)
                    }
                    Spacer()
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(ThemeColors.accent)
                }
                .padding(14)
            }
            .buttonStyle(.plain)

            if expanded {
                Divider().overlay(ThemeColors.cardBorder)
                VStack(spacing: 10) {
                    ForEach(section.items) { summary in
                        seriesExpenseItem(summary)
                    }
                }
                .padding(12)
            }
        }
        .modernCard(radius: 16)
    }

    private func seriesExpenseItem(_ summary: SeriesExpenseSummary) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(summary.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(ThemeColors.textPrimary)

                HStack(spacing: 8) {
                    Text(summary.frequency.displayTitle)
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(ThemeColors.accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(ThemeColors.accent.opacity(0.12))
                        .clipShape(Capsule())
                    if let monthlyAmount = summary.monthlyAmount {
                        Text("₹\(Int(monthlyAmount))/mo")
                            .font(.caption)
                            .foregroundColor(ThemeColors.textSecondary)
                    }
                }
            }

            Spacer()

            Text("₹\(Int(summary.displayTotal))")
                .font(.subheadline.weight(.bold))
                .foregroundColor(ThemeColors.textPrimary)
        }
        .padding(12)
        .background(ThemeColors.cardElevated)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var yearlySeriesSections: [YearExpenseSection] {
        let groupedByYear = Dictionary(grouping: expenses) { $0.year }

        return groupedByYear
            .map { year, yearlyExpenses in
                let groupedBySeries = Dictionary(grouping: yearlyExpenses) { $0.seriesId }

                let summaries: [SeriesExpenseSummary] = groupedBySeries.compactMap { _, seriesExpenses in
                    guard let representative = seriesExpenses.first else { return nil }
                    let frequency = representative.frequency

                    let displayTotal: Double
                    let monthlyAmount: Double?
                    if frequency == .monthly {
                        displayTotal = seriesExpenses.reduce(0) { $0 + $1.amount }
                        monthlyAmount = representative.amount
                    } else {
                        displayTotal = representative.amount
                        monthlyAmount = nil
                    }

                    return SeriesExpenseSummary(
                        id: representative.seriesId,
                        name: representative.name,
                        displayTotal: displayTotal,
                        monthlyAmount: monthlyAmount,
                        frequency: representative.frequency,
                        startMonth: representative.startMonth,
                        startYear: representative.startYear,
                        endMonth: representative.endMonth,
                        endYear: representative.endYear
                    )
                }
                .sorted { $0.name < $1.name }

                return YearExpenseSection(year: year, items: summaries)
            }
            .sorted { $0.year < $1.year }
    }
}
