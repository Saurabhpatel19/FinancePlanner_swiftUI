import SwiftUI
import SwiftData

struct YearlyExpenseView: View {
    private enum FilterType: String, CaseIterable, Identifiable {
        case all = "All"
        case paid = "Paid"
        case unpaid = "Unpaid"
        var id: Self { self }
    }

    @Environment(\.modelContext) private var context
    @Query private var expenses: [ExpenseModel]

    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedFilter: FilterType = .all
    @State private var editingExpense: ExpenseModel?
    @State private var showingPaymentSheet: ExpenseModel?

    private var yearlyExpenses: [ExpenseModel] {
        expenses
            .filter { $0.frequency == .yearly && $0.year == selectedYear }
            .sorted(using: SortDescriptor(\ExpenseModel.month, order: .forward))
    }

    private var filteredYearlyExpenses: [ExpenseModel] {
        switch selectedFilter {
        case .all:
            return yearlyExpenses
        case .paid:
            return yearlyExpenses.filter(\.isPaid)
        case .unpaid:
            return yearlyExpenses.filter { !$0.isPaid }
        }
    }

    private var availableYears: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        return currentMonth > 10 ? [currentYear, currentYear + 1, currentYear + 2] : [currentYear, currentYear + 1]
    }

    private var plannedTotal: Double { yearlyExpenses.reduce(0) { $0 + $1.amount } }
    private var spentTotal: Double { yearlyExpenses.filter { $0.isPaid }.reduce(0) { $0 + $1.amount } }
    private var unpaidCount: Int { yearlyExpenses.filter { !$0.isPaid }.count }

    var body: some View {
        ZStack {
            AppBackground()

            NavigationStack {
                ScrollView {
                    VStack(spacing: 16) {
                        header
                        yearChips
                        summaryCard
                        expenseList
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 28)
                }
                .navigationBarHidden(true)
                .sheet(item: $editingExpense) { expense in
                    AddEditExpenseView(expense: expense, actionType: .update, context: context)
                }
                .sheet(item: $showingPaymentSheet) { expense in
                    PaymentDetailsSheet(expense: expense, context: context)
                }
                .onAppear {
                    if !availableYears.contains(selectedYear), let fallback = availableYears.first {
                        selectedYear = fallback
                    }
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Yearly Expenses")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(ThemeColors.textPrimary)
            Text("Plan annual commitments")
                .font(.subheadline)
                .foregroundColor(ThemeColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var yearChips: some View {
        HStack(spacing: 10) {
            ForEach(availableYears, id: \.self) { year in
                Text(String(year))
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(selectedYear == year ? .white : ThemeColors.textPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(selectedYear == year ? AnyShapeStyle(ThemeGradients.accentGradient) : AnyShapeStyle(ThemeColors.cardElevated))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(ThemeColors.cardBorder, lineWidth: 1))
                    .onTapGesture { withAnimation(.spring(duration: 0.24)) { selectedYear = year } }
            }
            Spacer()
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Year \(selectedYear)")
                .font(.headline)
                .foregroundColor(ThemeColors.textPrimary)

            HStack(spacing: 12) {
                metric("Planned", plannedTotal)
                metric("Paid", spentTotal)
                metric("Pending", max(0, plannedTotal - spentTotal))
            }

            if isCurrentYear {
                ProgressView(value: spentTotal, total: max(plannedTotal, 1))
                    .tint(ThemeColors.positive)
                    .scaleEffect(x: 1, y: 1.8)
                Text("\(unpaidCount) unpaid")
                    .font(.caption)
                    .foregroundColor(ThemeColors.textSecondary)
            }
        }
        .padding(16)
        .modernCard()
    }

    private func metric(_ label: String, _ value: Double) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundColor(ThemeColors.textSecondary)
            Text("₹\(Int(value))")
                .font(.subheadline.weight(.bold))
                .foregroundColor(ThemeColors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(ThemeColors.cardElevated)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var expenseList: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Expenses")
                    .font(.headline)
                    .foregroundColor(ThemeColors.textPrimary)
                Spacer()
                HStack(spacing: 6) {
                    ForEach(FilterType.allCases) { filter in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedFilter = filter
                            }
                        } label: {
                            Text(filter.rawValue)
                                .font(.caption2.weight(.semibold))
                                .foregroundColor(selectedFilter == filter ? .white : ThemeColors.textPrimary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(selectedFilter == filter ? AnyShapeStyle(ThemeGradients.accentGradient) : AnyShapeStyle(ThemeColors.cardElevated))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            if filteredYearlyExpenses.isEmpty {
                Text("No yearly expenses for \(selectedYear)")
                    .font(.subheadline)
                    .foregroundColor(ThemeColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 32)
                    .modernCard()
            } else {
                ForEach(filteredYearlyExpenses) { expense in
                    ExpenseCard(expense: expense, selectedYear: selectedYear) {
                        expense.togglePaid(forMonth: expense.month, year: expense.year)
                        if expense.isPaid { showingPaymentSheet = expense }
                    }
                    .onTapGesture { editingExpense = expense }
                }
            }
        }
    }

    private var isCurrentYear: Bool {
        selectedYear == Calendar.current.component(.year, from: Date())
    }
}
