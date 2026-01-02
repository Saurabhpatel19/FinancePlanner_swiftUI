//
//  HomeView.swift
//  FinancePlanner
//
//  Created by Saurabh on 01/01/26.
//


import SwiftUI
import SwiftData
import Charts


struct HomeView: View {

    private struct MonthItem: Identifiable, Equatable {
        let id = UUID()
        let month: Int
        let year: Int
    }
    
    @Environment(\.modelContext) private var context

    @Query private var expenses: [ExpenseModel]
    @State private var selectedMonthIndex = 0

    @State private var showAddExpense = false
    @State private var editingExpense: ExpenseModel?
    
    @State private var showingPaymentSheet: ExpenseModel?
    
    // MARK: - Month Data (Dynamic)
    private var months: [MonthItem] {
        let calendar = Calendar.current
        let now = Date()

        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)

        var result: [MonthItem] = []

        // current year (current month → Dec)
        for m in currentMonth...12 {
            result.append(MonthItem(month: m, year: currentYear))
        }

        // next year (Jan → Dec)
        for m in 1...12 {
            result.append(MonthItem(month: m, year: currentYear + 1))
        }

        // optional extra year if late in year
        if currentMonth >= 10 {
            for m in 1...12 {
                result.append(MonthItem(month: m, year: currentYear + 2))
            }
        }

        return result
    }

    private var selectedMonth: MonthItem {
        months[selectedMonthIndex]
    }

    // MARK: - Derived Values
    private var monthExpenses: [ExpenseModel] {
        expenses.filter {
            $0.month == selectedMonth.month &&
            $0.year == selectedMonth.year
        }
    }

    private var plannedTotal: Double {
        monthExpenses.reduce(0) { $0 + $1.amount }
    }

    private var spentTotal: Double {
        monthExpenses
            .filter { $0.isPaid }
            .reduce(0) { $0 + $1.amount }
    }

    private var unpaidCount: Int {
        monthExpenses.filter { !$0.isPaid }.count
    }

    private var fixedTotal: Double {
        monthExpenses
            .filter { $0.type == .fixed }
            .reduce(0) { $0 + $1.amount }
    }

    private var variableTotal: Double {
        monthExpenses
            .filter { $0.type == .variable }
            .reduce(0) { $0 + $1.amount }
    }

    // MARK: - UI
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    monthChips
                    monthSummary
                    
                    if monthExpenses.isEmpty {
                        emptyState
                    } else {
                        if isCurrentMonth {
                            progressSection
                            fixedVariableChart
                        }
                        expenseList
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("My Finance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button {
                    showAddExpense = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddExpense) {
            AddEditExpenseView(
                expense: ExpenseModel(
                    name: "",
                    amount: 0,
                    type: .fixed,
                    frequency: .monthly,
                    month: selectedMonth.month,
                    year: selectedMonth.year
                ),
                actionType: .add,
                context: context
            )
        }

        .sheet(item: $editingExpense) { expense in
            AddEditExpenseView(
                expense: expense,
                actionType: .update,
                context: context
            )
        }
        
        .sheet(item: $showingPaymentSheet) { expense in
            PaymentDetailsSheet(
                expense: expense,
                context: context
            )
        }
    }
    
    //MARK: -
    private var monthChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(months.indices, id: \.self) { index in
                    let month = months[index]

                    Text(shortMonthTitle(month: month.month, year: month.year))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selectedMonthIndex == index
                                      ? Color.accentColor
                                      : Color(.systemGray5))
                        )
                        .foregroundColor(
                            selectedMonthIndex == index ? .white : .primary
                        )
                        .onTapGesture {
                            selectedMonthIndex = index
                        }
                }
            }
        }
    }
        
    private var monthSummary: some View {
        VStack(spacing: 6) {
            Text(fullMonthTitle(month: selectedMonth.month, year: selectedMonth.year))
                .font(.title2.weight(.semibold))

            if isCurrentMonth {
                Text("₹\(Int(plannedTotal)) • \(unpaidCount) unpaid")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Text("Expected Expense ₹\(Int(plannedTotal))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

    var emptyState: some View {
        VStack(spacing: 12) {
            Spacer(minLength: 60)
            Image(systemName: "tray")
                .font(.largeTitle)
                .foregroundColor(.secondary)

            Text("No expenses for this month")
                .font(.headline)

            Text("Tap + to add your first expense")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text("Spent ₹\(Int(spentTotal)) / Planned ₹\(Int(plannedTotal))")
                .font(.caption)
                .foregroundColor(.secondary)

            ProgressView(value: spentTotal, total: plannedTotal == 0 ? 1 : plannedTotal)
                .progressViewStyle(.linear)
                .tint(.accentColor)
                .scaleEffect(x: 1, y: 2.5, anchor: .center)   // ⬅️ height
            
        }
        .padding(.horizontal)
    }

    private var fixedVariableChart: some View {
        VStack(spacing: 12) {

            Chart {
                if fixedTotal > 0 {
                    SectorMark(
                        angle: .value("Fixed", fixedTotal)
                    )
                    .foregroundStyle(Color.blue.opacity(0.6))
                }

                if variableTotal > 0 {
                    SectorMark(
                        angle: .value("Variable", variableTotal)
                    )
                    .foregroundStyle(Color.gray.opacity(0.6))
                }
            }
            .frame(height: 160)

            // 👇 Simple legend with values
            HStack(spacing: 24) {

                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.blue.opacity(0.6))
                        .frame(width: 10, height: 10)

                    Text("Fixed ₹\(Int(fixedTotal))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.gray.opacity(0.6))
                        .frame(width: 10, height: 10)

                    Text("Variable ₹\(Int(variableTotal))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private var expenseList: some View {
        VStack(spacing: 12) {

            if monthExpenses.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(monthExpenses) { expense in
                        ExpenseCard(
                            expense: expense,
                            isCurrentMonth: isCurrentMonth
                        ) {
                            expense.togglePaid(
                                forMonth: expense.month,
                                year: expense.year
                            )
                            
                            if expense.isPaid {
                                showingPaymentSheet = expense
                            }
                        }
                        .onTapGesture {
                            editingExpense = expense
                        }
                    }
                }
            }
        }
    }
    
    var isCurrentMonth: Bool {
        let now = Date()
        let cal = Calendar.current
        return selectedMonth.month == cal.component(.month, from: now) &&
               selectedMonth.year == cal.component(.year, from: now)
    }
    
    private func fullMonthTitle(month: Int, year: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"

        let date = Calendar.current.date(
            from: DateComponents(year: year, month: month)
        )!

        return formatter.string(from: date)
    }

    private func shortMonthTitle(month: Int, year: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yy"

        let date = Calendar.current.date(
            from: DateComponents(year: year, month: month)
        )!

        return formatter.string(from: date)
    }

}
