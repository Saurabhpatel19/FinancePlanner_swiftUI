//
//  HomeView.swift
//  FinancePlanner
//
//  Created by Saurabh on 25/12/25.
//


import SwiftUI
import SwiftData

// MARK: - Month UI Model
struct MonthUI: Identifiable {
    let id = UUID()
    let month: Int
    let year: Int
    let title: String
}

struct HomeView: View {

    // MARK: - SwiftData
    @Environment(\.modelContext) private var context
    @Query(sort: \MonthModel.title) private var storedMonths: [MonthModel]

    // MARK: - Onboarding
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    // MARK: - UI State
    @State private var selectedMonthIndex: Int = 0
    @State private var showAddExpenseSheet = false
    @State private var editingExpense: ExpenseModel?

    // MARK: - Months
    var monthsUI: [MonthUI] {
        let calendar = Calendar.current
        let now = Date()

        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"

        var months: [MonthUI] = []

        // Current year: current month → December
        for month in currentMonth...12 {
            if let date = calendar.date(from: DateComponents(year: currentYear, month: month)) {
                months.append(
                    MonthUI(
                        month: month,
                        year: currentYear,
                        title: formatter.string(from: date)
                    )
                )
            }
        }

        // If Oct or later → add full next year
        if currentMonth >= 10 {
            let nextYear = currentYear + 1
            for month in 1...12 {
                if let date = calendar.date(from: DateComponents(year: nextYear, month: month)) {
                    months.append(
                        MonthUI(
                            month: month,
                            year: nextYear,
                            title: formatter.string(from: date)
                        )
                    )
                }
            }
        }

        return months
    }

    var selectedMonthUI: MonthUI {
        monthsUI[selectedMonthIndex]
    }

    var selectedMonthModel: MonthModel? {
        storedMonths.first { $0.title == selectedMonthUI.title }
    }

    var fixedTotal: Double {
        selectedMonthModel?.fixedExpenses.reduce(0) { $0 + $1.amount } ?? 0
    }

    var variableTotal: Double {
        selectedMonthModel?.variableExpenses.reduce(0) { $0 + $1.amount } ?? 0
    }

    var isEmptyMonth: Bool {
        fixedTotal == 0 && variableTotal == 0
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {

                ScrollView {
                    VStack(spacing: 16) {

                        // Month selector
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(monthsUI.indices, id: \.self) { index in
                                    let item = monthsUI[index]

                                    Text(item.title.prefix(3) + " \(item.year)")
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            selectedMonthIndex == index
                                            ? Color.blue.opacity(0.25)
                                            : Color.gray.opacity(0.15)
                                        )
                                        .cornerRadius(12)
                                        .onTapGesture {
                                            selectedMonthIndex = index
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Empty state
                        if isEmptyMonth {
                            VStack(spacing: 12) {
                                Spacer(minLength: 40)

                                Text("Start planning your finance now")
                                    .font(.title3.bold())
                                    .multilineTextAlignment(.center)

                                Text("Add your fixed and variable expenses to plan your month.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)

                                Spacer()
                            }
                        } else {

                            // Summary
                            VStack(spacing: 8) {
                                summaryRow("Fixed", fixedTotal)
                                summaryRow("Variable", variableTotal)
                                Divider()
                                summaryRow("TOTAL", fixedTotal + variableTotal, bold: true)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(radius: 2)

                            // Fixed expenses
                            section("FIXED EXPENSES") {
                                ForEach(selectedMonthModel?.fixedExpenses ?? []) { expense in
                                    expenseRow(expense)
                                }
                            }

                            // Variable expenses
                            section("VARIABLE EXPENSES") {
                                ForEach(selectedMonthModel?.variableExpenses ?? []) { expense in
                                    expenseRow(expense)
                                }
                            }
                        }
                    }
                    .padding()
                }

                // Floating Add Button
                floatingAddButton
            }
            .navigationTitle("My Finance")
        }

        // Onboarding
        .fullScreenCover(isPresented: .constant(!hasSeenOnboarding)) {
            OnboardingView {
                showAddExpenseSheet = true
            }
        }

        // Add Expense
        .sheet(isPresented: $showAddExpenseSheet) {
            let monthUI = monthsUI[selectedMonthIndex]

            AddEditExpenseView(
                expense: ExpenseModel(
                    name: "",
                    amount: 0,
                    type: .fixed,
                    frequency: .monthly,
                    month: monthUI.month,
                    year: monthUI.year
                ),
                monthsUI: monthsUI,
                selectedMonthIndex: selectedMonthIndex,
                actionType: expenseActionType.add
            )
        }

        // Edit Expense
        .sheet(item: $editingExpense) { expense in
            AddEditExpenseView(
                expense: expense,
                monthsUI: monthsUI,
                selectedMonthIndex: selectedMonthIndex,
                actionType: expenseActionType.update
            )
        }
    }

    // MARK: - Expense Row
    func expenseRow(_ expense: ExpenseModel) -> some View {
        let month = selectedMonthUI.month
        let year = selectedMonthUI.year
        let isPaidThisMonth = expense.isPaid

        return HStack {

            // Checkbox (current month only)
            if isCurrentMonthSelected {
                Button {
                    expense.togglePaid(forMonth: month, year: year)
                } label: {
                    Image(systemName: isPaidThisMonth
                          ? "checkmark.circle.fill"
                          : "circle")
                        .foregroundColor(isPaidThisMonth ? .green : .secondary)
                }
                .buttonStyle(.plain)
            }

            Text(expense.name)
                .strikethrough(isPaidThisMonth && isCurrentMonthSelected)
                .foregroundColor(isPaidThisMonth ? .secondary : .primary)

            Spacer()

            Text("₹\(Int(expense.amount))")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .onTapGesture {
            editingExpense = expense
        }
    }

    // MARK: - Helpers
    var isCurrentMonthSelected: Bool {
        let now = Date()
        let cal = Calendar.current
        let selected = monthsUI[selectedMonthIndex]
        return selected.month == cal.component(.month, from: now)
            && selected.year == cal.component(.year, from: now)
    }

    func summaryRow(_ title: String, _ value: Double, bold: Bool = false) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text("₹\(Int(value))")
                .fontWeight(bold ? .bold : .regular)
        }
    }

    func section<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            content()
        }
    }

    // MARK: - Floating Button
    private var floatingAddButton: some View {
        Button {
            showAddExpenseSheet = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(radius: 4)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 24)
    }
}


