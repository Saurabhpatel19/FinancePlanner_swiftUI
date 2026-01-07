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
        ZStack {
            ThemeColors.background
                .ignoresSafeArea()
            
            NavigationStack {
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("All Expenses")
                            .font(.system(size: 32, weight: .bold, design: .default))
                            .foregroundColor(ThemeColors.textPrimary)
                        
                        Text("Complete expense history")
                            .font(.caption)
                            .foregroundColor(ThemeColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    
                    // Content
                    ScrollView {
                        VStack(spacing: 16) {
                            if yearlySeriesSections.isEmpty {
                                emptyState
                            } else {
                                ForEach(yearlySeriesSections) { section in
                                    yearSectionCard(section)
                                }
                            }
                        }
                        .padding(20)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
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
    }
    
    var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(ThemeColors.accent.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "tray")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(ThemeColors.accent)
            }
            
            VStack(spacing: 4) {
                Text("No expenses yet")
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundColor(ThemeColors.textPrimary)
                
                Text("Start adding expenses to see them here")
                    .font(.caption)
                    .foregroundColor(ThemeColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    
    func yearSectionCard(_ section: YearExpenseSection) -> some View {
        VStack(spacing: 0) {
            // Header Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if expandedYears.contains(section.year) {
                        expandedYears.remove(section.year)
                    } else {
                        expandedYears.insert(section.year)
                    }
                }
            }) {
                let total = section.items.reduce(0) { $0 + $1.displayTotal }
                let isExpanded = expandedYears.contains(section.year)
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Text(String(section.year))
                                .font(.system(size: 18, weight: .bold, design: .default))
                                .foregroundColor(ThemeColors.textPrimary)
                            
                            Text("\(section.items.count) items")
                                .font(.caption)
                                .foregroundColor(ThemeColors.textSecondary)
                        }
                        
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Total")
                                    .font(.caption2)
                                    .foregroundColor(ThemeColors.textSecondary)
                                
                                Text("₹\(Int(total))")
                                    .font(.system(size: 16, weight: .semibold, design: .default))
                                    .foregroundColor(ThemeColors.positive)
                            }
                            
                            Spacer()
                        }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(ThemeColors.accent)
                            .frame(width: 24, height: 24)
                    }
                }
                .padding(16)
            }
            .buttonStyle(.plain)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        ThemeColors.cardBackground,
                        ThemeColors.cardBackground.opacity(0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
            // Expanded Content
            if expandedYears.contains(section.year) {
                Divider()
                    .background(ThemeColors.cardBorder)
                
                VStack(spacing: 12) {
                    ForEach(section.items) { summary in
                        seriesExpenseItem(summary)
                    }
                }
                .padding(16)
            }
        }
        .background(ThemeColors.cardBackground)
        .border(ThemeColors.cardBorder, width: 1)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
    
    func seriesExpenseItem(_ summary: SeriesExpenseSummary) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(summary.name)
                        .font(.system(size: 14, weight: .semibold, design: .default))
                        .foregroundColor(ThemeColors.textPrimary)
                    
                    HStack(spacing: 8) {
                        // Frequency badge
                        Text(summary.frequency.displayTitle)
                            .font(.caption2)
                            .foregroundColor(ThemeColors.accent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(ThemeColors.accent.opacity(0.1))
                            .cornerRadius(4)
                        
                        if let monthlyAmount = summary.monthlyAmount {
                            Text("₹\(Int(monthlyAmount))/mo")
                                .font(.caption2)
                                .foregroundColor(ThemeColors.textSecondary)
                        }
                        
                        Spacer()
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("₹\(Int(summary.displayTotal))")
                        .font(.system(size: 15, weight: .bold, design: .default))
                        .foregroundColor(ThemeColors.textPrimary)
                }
            }
            .padding(12)
            .background(ThemeColors.background.opacity(0.5))
            .cornerRadius(8)
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
        EmptyView()
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
