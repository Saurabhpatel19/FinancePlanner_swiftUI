//
//  YearlyExpenseView.swift
//  FinancePlanner
//
//  Created by Saurabh on 29/12/25.
//


//
//  YearlyExpenseView.swift
//  FinancePlanner
//
//  Created by Saurabh on 29/12/25.
//


import SwiftUI
import SwiftData

struct YearlyExpenseView: View {

    // MARK: - Data
    @Query private var expenses: [ExpenseModel]

    // MARK: - State
    @State private var selectedYear =
        Calendar.current.component(.year, from: Date())

    // MARK: - Computed
    private var yearlyExpenses: [ExpenseModel] {
        let yearlyExpenses = expenses.filter { $0.frequency == .yearly && $0.year == selectedYear }
        return yearlyExpenses.sorted(using: SortDescriptor(\ExpenseModel.month, order: .forward))
    }


    private var availableYears: [Int] {
        let calendar = Calendar.current
        let now = Date()

        let currentYear = calendar.component(.year, from: now)
        let currentMonth = calendar.component(.month, from: now)

        // Same rule as Home
        if currentMonth > 10 {
            return [currentYear, currentYear + 1, currentYear + 2]
        } else {
            return [currentYear]
        }
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 16) {

            // Title
            Text("Yearly Expenses")
                .font(.title2.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            // Year chips
            yearChips

            // Expense list
            yearlyExpenseList

            Spacer()
        }
        .padding(.top)
        .onAppear {
            if !availableYears.contains(selectedYear) {
                selectedYear = availableYears.first!
            }
        }
    }
}

// MARK: - Year Chips
private extension YearlyExpenseView {

    var yearChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(availableYears, id: \.self) { year in
                    yearChip(year)
                }
            }
            .padding(.horizontal)
        }
    }

    func yearChip(_ year: Int) -> some View {
        Text(String(year)) // prevents "2,025"
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(selectedYear == year
                          ? Color.accentColor
                          : Color(.systemGray5))
            )
            .foregroundColor(
                selectedYear == year ? .white : .primary
            )
            .onTapGesture {
                withAnimation(.easeInOut) {
                    selectedYear = year
                }
            }
    }
}

// MARK: - Expense List
private extension YearlyExpenseView {

    var yearlyExpenseList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(yearlyExpenses) { expense in
                    YearlyExpenseCard(
                        expense: expense,
                        year: selectedYear
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}
