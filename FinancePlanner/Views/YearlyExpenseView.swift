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

    @Environment(\.modelContext) private var context

    // MARK: - Data
    @Query private var expenses: [ExpenseModel]

    // MARK: - State
    @State private var selectedYear =
        Calendar.current.component(.year, from: Date())
    
    @State private var editingExpense: ExpenseModel?
    
    @State private var showingPaymentSheet: ExpenseModel?
    @State private var showAddExpense = false

    private var plannedTotal: Double {
        yearlyExpenses.reduce(0) { $0 + $1.amount }
    }

    private var spentTotal: Double {
        yearlyExpenses
            .filter { $0.isPaid }
            .reduce(0) { $0 + $1.amount }
    }

    private var unpaidCount: Int {
        yearlyExpenses.filter { !$0.isPaid }.count
    }
    
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
            return [currentYear, currentYear + 1]
        }
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            ThemeColors.background
                .ignoresSafeArea()
            
            NavigationStack {
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Header
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Yearly Expenses")
                                .font(.system(size: 32, weight: .bold, design: .default))
                                .foregroundColor(ThemeColors.textPrimary)
                            
                            Text("Plan your annual budget")
                                .font(.caption)
                                .foregroundColor(ThemeColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        // Year selector
                        yearChips
                        
                        // Progress/Summary card
                        if isCurrentYear {
                            yearlyProgressSection
                        } else {
                            yearSummaryCard
                        }
                        
                        // Expense list
                        yearlyExpenseList
                    }
                    .padding(.bottom, 20)
                }
                .navigationBarTitleDisplayMode(.inline)
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
                .onAppear {
                    if !availableYears.contains(selectedYear) {
                        selectedYear = availableYears.first!
                    }
                }
            }
        }
    }

}

// MARK: - Year Chips
private extension YearlyExpenseView {

    var yearChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(availableYears, id: \.self) { year in
                    Text(String(year))
                        .font(.system(size: 14, weight: .semibold, design: .default))
                        .frame(minWidth: 60)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(
                            selectedYear == year ?
                            ThemeGradients.accentGradient :
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    ThemeColors.cardBackground,
                                    ThemeColors.cardBackground.opacity(0.8)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundColor(selectedYear == year ? .white : ThemeColors.textPrimary)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    selectedYear == year ? ThemeColors.accentPurple : ThemeColors.cardBorder,
                                    lineWidth: 1
                                )
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedYear = year
                            }
                        }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Expense List
private extension YearlyExpenseView {
    
    var yearlyExpenseList: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text("Expenses")
                .font(.system(size: 14, weight: .semibold, design: .default))
                .foregroundColor(ThemeColors.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)
                .padding(.horizontal, 20)
            
            if yearlyExpenses.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(ThemeColors.accent)
                    
                    Text("No expenses for \(selectedYear)")
                        .font(.system(size: 14, weight: .medium, design: .default))
                        .foregroundColor(ThemeColors.textPrimary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(yearlyExpenses) { expense in
                            ExpenseCard(
                                expense: expense,
                                selectedYear: selectedYear
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
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    var yearSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Year \(selectedYear)")
                .font(.system(size: 16, weight: .semibold, design: .default))
                .foregroundColor(ThemeColors.textPrimary)
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Planned")
                        .font(.caption2)
                        .foregroundColor(ThemeColors.textSecondary)
                    
                    Text("₹\(Int(plannedTotal))")
                        .font(.system(size: 18, weight: .bold, design: .default))
                        .foregroundColor(ThemeColors.textPrimary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Expenses")
                        .font(.caption2)
                        .foregroundColor(ThemeColors.textSecondary)
                    
                    Text("\(yearlyExpenses.count)")
                        .font(.system(size: 18, weight: .bold, design: .default))
                        .foregroundColor(ThemeColors.textPrimary)
                }
            }
        }
        .padding(16)
        .background(ThemeColors.cardBackground)
        .border(ThemeColors.cardBorder, width: 1)
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
    
    private var yearlyProgressSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Year \(selectedYear) Progress")
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundColor(ThemeColors.textPrimary)
                
                Text("₹\(Int(plannedTotal)) planned • \(unpaidCount) unpaid")
                    .font(.caption)
                    .foregroundColor(ThemeColors.textSecondary)
            }
            
            VStack(spacing: 8) {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(ThemeColors.cardBorder)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(ThemeGradients.positiveGradient)
                        .frame(width: plannedTotal == 0 ? 0 : CGFloat(spentTotal / plannedTotal) * UIScreen.main.bounds.width * 0.7)
                }
                .frame(height: 8)
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Spent")
                            .font(.caption2)
                            .foregroundColor(ThemeColors.textSecondary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(ThemeColors.positive)
                            
                            Text("₹\(Int(spentTotal))")
                                .font(.system(size: 13, weight: .semibold, design: .default))
                                .foregroundColor(ThemeColors.textPrimary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Remaining")
                            .font(.caption2)
                            .foregroundColor(ThemeColors.textSecondary)
                        
                        Text("₹\(Int(max(0, plannedTotal - spentTotal)))")
                            .font(.system(size: 13, weight: .semibold, design: .default))
                            .foregroundColor(ThemeColors.textPrimary)
                    }
                }
            }
        }
        .padding(16)
        .background(ThemeColors.cardBackground)
        .border(ThemeColors.cardBorder, width: 1)
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
    
    var isCurrentYear: Bool {
        let now = Date()
        let cal = Calendar.current
        return selectedYear == cal.component(.year, from: now)
    }
}
