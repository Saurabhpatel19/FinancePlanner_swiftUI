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
        ZStack {
            ThemeColors.background
                .ignoresSafeArea()
            
            NavigationStack {
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Header with title and add button
                        VStack(alignment: .leading, spacing: 4) {
                            Text("My Finance")
                                .font(.system(size: 32, weight: .bold, design: .default))
                                .foregroundColor(ThemeColors.textPrimary)
                            
                            Text("Track your monthly expenses")
                                .font(.caption)
                                .foregroundColor(ThemeColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        // Month selector
                        monthChips
                        
                        if monthExpenses.isEmpty {
                            emptyState
                        } else {
                            // Monthly progress card
                            monthlyProgressSection
                            
                            // Fixed vs Variable breakdown
                            breakdownCard
                            
                            // Expense list
                            expenseList
                        }
                    }
                    .padding(.bottom, 20)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showAddExpense = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(ThemeColors.accent)
                        }
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
    }
    //MARK: - Month Chips
    var monthChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(months.indices, id: \.self) { index in
                    let month = months[index]
                    
                    VStack(spacing: 2) {
                        Text(shortMonthTitle(month: month.month, year: month.year))
                            .font(.system(size: 12, weight: .semibold, design: .default))
                    }
                    .frame(minWidth: 54)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(
                        selectedMonthIndex == index ?
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
                    .foregroundColor(selectedMonthIndex == index ? .white : ThemeColors.textPrimary)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                selectedMonthIndex == index ? ThemeColors.accentPurple : ThemeColors.cardBorder,
                                lineWidth: 1
                            )
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedMonthIndex = index
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
    }
    
    var monthSummary: some View {
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
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 40)
            
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
                
                Text("Add your first expense to get started")
                    .font(.caption)
                    .foregroundColor(ThemeColors.textSecondary)
            }
            
            Spacer()
                .frame(height: 40)
        }
        .frame(maxWidth: .infinity)
    }
    
    var monthlyProgressSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text(fullMonthTitle(month: selectedMonth.month, year: selectedMonth.year))
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .foregroundColor(ThemeColors.textPrimary)
                
                if isCurrentMonth {
                    Text("₹\(Int(plannedTotal)) planned • \(unpaidCount) unpaid")
                        .font(.caption)
                        .foregroundColor(ThemeColors.textSecondary)
                } else {
                    Text("Expected expense: ₹\(Int(plannedTotal))")
                        .font(.caption)
                        .foregroundColor(ThemeColors.textSecondary)
                }
            }
            
            if isCurrentMonth {
                // Progress bar
                VStack(spacing: 8) {
                    ProgressView(
                        value: spentTotal,
                        total: plannedTotal == 0 ? 1 : plannedTotal
                    )
                    .progressViewStyle(.linear)
                    .tint(ThemeGradients.positiveGradient)
                    .scaleEffect(x: 1, y: 2.5)
                    .background(Color.white.opacity(0.6))
                    .animation(.easeInOut, value: spentTotal)
                    
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
            } else {
                // Expected expense card (non-current month)
                VStack(spacing: 8) {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(ThemeColors.cardBorder)
                    }
                    .frame(height: 0)
                    .frame(height: 0)
                }
            }
        }
        .padding(16)
        .background(ThemeColors.cardBackground)
        .border(ThemeColors.cardBorder, width: 1)
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
    
    var statsGrid: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatCard(
                    icon: "banknote",
                    title: "Total Planned",
                    amount: Int(plannedTotal),
                    color: .blue
                )
                
                StatCard(
                    icon: "checkmark.circle",
                    title: "Spent",
                    amount: Int(spentTotal),
                    color: .green
                )
            }
            
            HStack(spacing: 12) {
                StatCard(
                    icon: "square.stack",
                    title: "Fixed",
                    amount: Int(fixedTotal),
                    color: .purple
                )
                
                StatCard(
                    icon: "chart.bar",
                    title: "Variable",
                    amount: Int(variableTotal),
                    color: .orange
                )
            }
        }
        .padding(.horizontal, 20)
    }
    
    var breakdownCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Breakdown")
                .font(.system(size: 14, weight: .semibold, design: .default))
                .foregroundColor(ThemeColors.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)
            
            VStack(spacing: 10) {
                breakdownItem(title: "Fixed Expenses", amount: Int(fixedTotal), color: ThemeColors.accentPurple)
                
                Divider()
                    .background(ThemeColors.cardBorder)
                
                breakdownItem(title: "Variable Expenses", amount: Int(variableTotal), color: ThemeColors.accent)
            }
        }
        .padding(16)
        .background(ThemeColors.cardBackground)
        .border(ThemeColors.cardBorder, width: 1)
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
    
    func breakdownItem(title: String, amount: Int, color: Color) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .default))
                .foregroundColor(ThemeColors.textPrimary)
            
            Spacer()
            
            HStack(spacing: 4) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                
                Text("₹\(amount)")
                    .font(.system(size: 14, weight: .semibold, design: .default))
                    .foregroundColor(ThemeColors.textPrimary)
            }
        }
    }
    
    var monthlySummaryView: some View {
        EmptyView()
    }
    
    
    
    func summaryItem(
        color: Color,
        title: String,
        amount: Double
    ) -> some View
    {
        
        HStack(alignment: .center,spacing: 6) {
            
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
            
            Text("₹\(Int(amount))")
                .font(.caption.weight(.semibold))
                .foregroundColor(.primary)
        }
    }
    
    
    var fixedVariableChart: some View {
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
    
    var expenseList: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text("Expenses")
                .font(.system(size: 14, weight: .semibold, design: .default))
                .foregroundColor(ThemeColors.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)
                .padding(.horizontal, 20)
            
            if monthExpenses.isEmpty {
                Text("No expenses")
                    .foregroundColor(ThemeColors.textSecondary)
                    .padding(.horizontal, 20)
            } else {
                LazyVStack(spacing: 10) {
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
                .padding(.horizontal, 20)
            }
        }
    }
    
    var isCurrentMonth: Bool {
        let now = Date()
        let cal = Calendar.current
        return selectedMonth.month == cal.component(.month, from: now) &&
        selectedMonth.year == cal.component(.year, from: now)
    }
    
    func fullMonthTitle(month: Int, year: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        
        let date = Calendar.current.date(
            from: DateComponents(year: year, month: month)
        )!
        
        return formatter.string(from: date)
    }
    
    func shortMonthTitle(month: Int, year: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yy"
        
        let date = Calendar.current.date(
            from: DateComponents(year: year, month: month)
        )!
        
        return formatter.string(from: date)
    }
}

// MARK: - StatCard Component
struct StatCard: View {
    let icon: String
    let title: String
    let amount: Int
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .default))
                .foregroundColor(ThemeColors.textSecondary)
            
            Text("₹\(amount)")
                .font(.system(size: 18, weight: .bold, design: .default))
                .foregroundColor(ThemeColors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    color.opacity(0.08),
                    color.opacity(0.04)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .border(color.opacity(0.2), width: 1)
        .cornerRadius(10)
    }
}
