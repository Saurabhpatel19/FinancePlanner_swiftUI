//
//  AllExpensesView.swift
//  FinancePlanner
//
//  Created by Saurabh on 29/12/25.
//


import SwiftUI
import SwiftData

struct AllExpensesView: View {

    // MARK: - Data
    @Query(sort: [
        SortDescriptor(\ExpenseModel.year, order: .forward),
        SortDescriptor(\ExpenseModel.month, order: .forward)
    ])
    private var expenses: [ExpenseModel]

    @State private var expandedYears: Set<Int> = []
   
    // MARK: - Body
    var body: some View {
        NavigationStack {
            List {
                ForEach(yearlySeriesSections) { section in
                    Section {
                        if expandedYears.contains(section.year) {
                            ForEach(section.items) { summary in
                                SeriesExpenseRow(summary: summary)
                                    .listRowInsets(
                                        EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16)
                                    )
                                    .listRowSeparator(.hidden)
                            }
                        }
                    } header: {
                        yearHeader(year: section.year, items: section.items)
                    }
                }
            }
            .listStyle(.plain)
            .listSectionSeparator(.hidden)
            .navigationTitle("All Expenses")
            .onAppear {
                let currentYear = Calendar.current.component(.year, from: Date())
                expandedYears = Set(
                    yearlySeriesSections
                        .map(\.year)
                        .filter { $0 <= currentYear }
                )
            }
        }
    }
            
    private var expensesByYear: [(year: Int, items: [ExpenseModel])] {
        let grouped = Dictionary(grouping: expenses) { $0.year }

        return grouped
            .map { (year: $0.key, items: $0.value.sorted {
                ($0.month, $0.name) < ($1.month, $1.name)
            }) }
            .sorted { $0.year < $1.year }
    }

    private func yearHeader(year: Int, items: [SeriesExpenseSummary]) -> some View {

        let total = items.reduce(0) { $0 + $1.displayTotal }

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                if expandedYears.contains(year) {
                    expandedYears.remove(year)
                } else {
                    expandedYears.insert(year)
                }
            }
        } label: {
            PurpleGradientCard {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(year))
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)

                        Text("Total: ₹\(Int(total))")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                    }

                    Spacer()

                    Image(systemName: "chevron.down")
                        .rotationEffect(
                            .degrees(expandedYears.contains(year) ? 0 : -90)
                        )
                        .foregroundColor(.white)
                        .imageScale(.medium)
                }
                .padding(.trailing, 8)
            }
        }
        .buttonStyle(.plain)
    }

    private var yearlySeriesSections: [YearExpenseSection] {

        let groupedByYear = Dictionary(grouping: expenses) { $0.year }

        return groupedByYear
            .map { year, yearlyExpenses in

                let groupedBySeries = Dictionary(grouping: yearlyExpenses) { $0.seriesId }

                let summaries: [SeriesExpenseSummary] = groupedBySeries.compactMap { _, seriesExpenses in
                    guard let representativeOLF = seriesExpenses.first else { return nil }
                    
                    let representative = seriesExpenses.first!
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

                return YearExpenseSection(
                    year: year,
                    items: summaries
                )
            }
            .sorted { $0.year < $1.year }
    }


}
