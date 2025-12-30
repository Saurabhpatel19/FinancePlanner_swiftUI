//
//  HomeView.swift
//  FinancePlanner
//
//  Created by Saurabh on 25/12/25.
//


import SwiftUI
import SwiftData

struct HomeView: View {

    // MARK: - Data
    @Environment(\.modelContext) private var context
    @Query private var expenses: [ExpenseModel]

    // MARK: - UI State
    @State private var selectedMonthIndex = 0
    @State private var showAddExpense = false
    @State private var editingExpense: ExpenseModel?

    // MARK: - Month UI (DISPLAY ONLY)
    private var monthsUI: [MonthUI] {
        MonthUI.generate()
    }

    private var selectedMonth: MonthUI {
        monthsUI[selectedMonthIndex]
    }

    // MARK: - Filtered Expenses
    private var monthExpenses: [ExpenseModel] {
        expenses.filter {
            $0.month == selectedMonth.month &&
            $0.year == selectedMonth.year
        }
    }

    private var totalAmount: Int {
        Int(monthExpenses.reduce(0) { $0 + $1.amount })
    }

    private var unpaidCount: Int {
        monthExpenses.filter { !$0.isPaid }.count
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                monthPicker
                monthHeader

                ScrollView {
                    if monthExpenses.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(monthExpenses) { expense in
                                HomeExpenseCard(
                                    expense: expense,
                                    isCurrentMonth: isCurrentMonth
                                ) {
                                    expense.togglePaid(
                                        forMonth: expense.month,
                                        year: expense.year
                                    )
                                }
                                .onTapGesture {
                                    editingExpense = expense
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("My Finance")
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
    }
}

// MARK: - Subviews
private extension HomeView {

    var monthPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(monthsUI.indices, id: \.self) { index in
                    let month = monthsUI[index]
                    Text(month.shortTitle)
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
            .padding(.horizontal)
        }
    }

    var monthHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(selectedMonth.title)
                .font(.largeTitle.bold())

            Text("₹\(totalAmount) • \(unpaidCount) unpaid")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
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

    var isCurrentMonth: Bool {
        let now = Date()
        let cal = Calendar.current
        return selectedMonth.month == cal.component(.month, from: now) &&
               selectedMonth.year == cal.component(.year, from: now)
    }
}


